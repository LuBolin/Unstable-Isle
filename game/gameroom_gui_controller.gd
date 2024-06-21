class_name GameroomGuiController
extends Control

var game_room: GameRoom:
	get: game_room = game_room if game_room else get_node("../.."); return game_room

@onready var menu_overlay = $MenuOverlay
@onready var hero_picker = $HeroPicker
@onready var round_info = $RoundInfo

func _ready():
	game_room.round.prep_started.connect(start_prep)
	game_room.round.round_started.connect(start_round)

func start_prep(seed: int):
	hero_picker.set_visible(not game_room.network.multiplayer.is_server())
	round_info.set_visible(true)

func start_round():
	hero_picker.set_visible(false)
