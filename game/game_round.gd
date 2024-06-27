class_name GameRound
extends Node

signal prep_started
signal hero_picked(hero_name, id)
signal round_started
signal hero_died(id)
signal round_ended

signal received_server_frame
signal received_client_input

var game_room: GameRoom:
	get: game_room = game_room if game_room else get_node(".."); return game_room

const draw_wait_duration = 0.2
var draw_wait_cooldown = null

# id: "hero_name"
var hero_choices = {}
# id: dead_or_alive_boolean
var is_dead_dict = {}


func _ready():
	hero_died.connect(_on_hero_died)

func reset():
	hero_choices.clear()
	is_dead_dict.clear()
	draw_wait_cooldown = null
	is_dead_dict.clear()
	for id in game_room.players:
		hero_choices[id] = null

func _on_hero_died(id):
	is_dead_dict[id] = true
	check_round_should_end()

func check_round_should_end(): # server side only
	if not game_room.mutiplayer.is_server():
		return
	var alive_count = len(game_room.players) - len(is_dead_dict)
	if alive_count > 1:
		return
	elif alive_count == 1:
		draw_wait_cooldown = draw_wait_duration
	else:
		draw_wait_cooldown == 0

# if this is not the sesrver,
# draw_wait_cooldown will always be null
func _physics_process(delta):
	if draw_wait_cooldown == null:
		return
	draw_wait_cooldown -= delta
	if draw_wait_cooldown > 0:
		return
	
	var winner_id = null
	for id in game_room.players:
		if id not in is_dead_dict:
			winner_id = id
			break
	game_room.network.announce_result.rpc(winner_id)
