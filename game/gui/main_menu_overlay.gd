extends Control


@onready var start_game_button = $StartGame
@onready var please_wait_panel = $PleaseWaitPanel

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

func _ready():
	game_room = gui_controller.game_room
	start_game_button.pressed.connect(_on_start_game)
	game_room.round.prep_started.connect(start_prep)

func start_prep(_game_seed: int):
	start_game_button.hide()
	please_wait_panel.hide()

func _on_start_game():
	game_room.network.request_start_game.rpc_id(1)

func update_player_list():
	var owner_id = game_room.owner_id
	var is_owner = game_room.multiplayer.get_unique_id() == owner_id
	if game_room.game_phase == game_room.PHASE.HOLD:
		start_game_button.set_visible(is_owner)
		please_wait_panel.set_visible(not is_owner)
	else:
		start_game_button.set_visible(false)
		please_wait_panel.set_visible(false)
	start_game_button.disabled = game_room.players.size() <= 1
