extends Control



@onready var start_game_button = $StartGame
@onready var disconnect_button = $BtmLeftVBox/Disconnect
@onready var close_room_button = $BtmLeftVBox/CloseRoom

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

func _ready():
	game_room = gui_controller.game_room
	start_game_button.pressed.connect(_on_start_game)
	disconnect_button.pressed.connect(_on_disconnect)
	close_room_button.pressed.connect(_on_close_room)
	game_room.round.prep_started.connect(start_prep)

func start_prep(_game_seed: int):
	start_game_button.hide()

func _on_start_game():
	game_room.network.request_start_game.rpc_id(1)

func _on_disconnect():
	game_room.disconnect_self()

func _on_close_room():
	game_room.network.request_close_room.rpc_id(1)

func update_player_list():
	var owner_id = game_room.owner_id
	var is_owner = game_room.multiplayer.get_unique_id() == owner_id
	if game_room.game_phase == game_room.PHASE.HOLD:
		start_game_button.set_visible(is_owner)
		close_room_button.set_visible(is_owner)
	else:
		start_game_button.set_visible(false)
		close_room_button.set_visible(false)
	start_game_button.disabled = game_room.players.size() <= 1
