class_name GameroomChat
extends HBoxContainer

@onready var chat_history = $ChatVBox/ChatHistory/ChatHistoryVBox
@onready var chat_input = $ChatVBox/ChatInput

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

const MAX_CHAT_HISTORY = 5

var is_chatting : bool :
	get:
		return chat_input.has_focus()

func _ready():
	game_room = gui_controller.game_room

func _input(event):
	if not event.is_pressed():
		return
	if chat_input.has_focus():
		if event is InputEventKey:
			if event.keycode == KEY_ENTER:
				var to_send = chat_input.get_text()
				chat_input.clear()
				if len(to_send) > 0:
					# send to server
					game_room.network.send_chat.rpc_id(1, to_send)
				chat_input.release_focus()
			elif event.keycode == KEY_ESCAPE:
				chat_input.clear()
				chat_input.release_focus()
	else:
		if event is InputEventKey and event.keycode == KEY_ENTER:
			chat_input.grab_focus()

func receive_msg(msg: String):
	var label = Label.new()
	label.set_text(msg)
	chat_history.add_child(label)
	if chat_history.get_child_count() > MAX_CHAT_HISTORY:
		# remove earliest child
		var earliest = chat_history.get_child(0)
		chat_history.remove_child(earliest)
		earliest.queue_free()
