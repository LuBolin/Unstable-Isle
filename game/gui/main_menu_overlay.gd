extends Control

@onready var start_game_button = $StartGame
@onready var disconnect_button = $Disconnect



@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

func _ready():
	game_room = gui_controller.game_room
	start_game_button.pressed.connect(_on_start_game)
	disconnect_button.pressed.connect(_on_disconnect)

func _on_start_game():
	pass

func _on_disconnect():
	pass

func update_player_list():
	var owner_id = game_room.owner_id
	var is_owner = game_room.multiplayer.get_unique_id() == owner_id
	start_game_button.set_visible(is_owner)
