class_name GameroomGuiController
extends Control

var game_room: GameRoom:
	get: game_room = game_room if game_room else get_node("../.."); return game_room

@onready var menu_overlay = $MenuOverlay
@onready var hero_picker = $HeroPicker
@onready var round_info = $RoundInfo
@onready var hero_info_hud = $HeroInfoHUD
@onready var chat = $Chat

var is_spectator = false

func _ready():
	game_room.round.prep_started.connect(start_prep)
	game_room.round.round_started.connect(start_round)
	game_room.game_ended.connect(game_ended)
	game_room.spectator_caughtup.connect(spectator_caughtup)

func start_prep(_game_seed: int):
	hero_picker.clear()
	hero_info_hud.clear()
	
	hero_picker.set_visible(not game_room.network.multiplayer.is_server())
	round_info.set_visible(true)
	hero_info_hud.hide()

func spectator_caughtup(_catchup_dict):
	hero_info_hud.hide()
	hero_picker.random_button.hide()
	chat.hide()
	is_spectator = true

func start_round():
	hero_picker.set_visible(false)
	if not is_spectator:
		hero_info_hud.set_visible(true)

func game_ended():
	menu_overlay.set_visible(false)
	hero_picker.set_visible(false)
	round_info.set_visible(true)
	hero_info_hud.set_visible(false)
