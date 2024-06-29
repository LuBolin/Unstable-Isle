class_name GameRound
extends Node

signal prep_started
signal hero_picked(hero_name, id)
signal round_started
signal hero_died(id)
signal round_ended(winner_id)

signal received_server_frame
signal received_client_input

var game_room: GameRoom:
	get: game_room = game_room if game_room else get_node(".."); return game_room

var draw_wait_cooldown = null

# id: "hero_name"
var hero_choices = {}
# id: dead_or_alive_boolean
var is_dead_dict = {}


func _ready():
	hero_died.connect(_on_hero_died)
	round_ended.connect(_on_round_ended)
	round_started.connect( # for the sake of 1 player lobbies
		func(): get_tree().create_timer(1).timeout.connect(check_round_should_end))

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
	# all disconnected players will be set to dead when a round starts
	var alive_count = len(game_room.players) - len(is_dead_dict)
	if alive_count > 1:
		return
	elif alive_count == 1:
		draw_wait_cooldown = Settings.DRAW_WAIT_DURATION
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
	draw_wait_cooldown = null
	game_room.network.announce_round_result.rpc(winner_id)

func _on_round_ended(winner_id):
	if not game_room.multiplayer.is_server():
		return
	if winner_id:
		game_room.players[winner_id]['score'] += 1
	get_tree().create_timer(3).timeout.connect(
		func():
			if winner_id and game_room\
				.players[winner_id]['score'] == Settings.SCORE_TO_WIN:
				game_room.network.announce_game_ended.rpc()
				get_tree().create_timer(\
					Settings.DISPLAY_FINAL_RESULT_DURATION).\
					timeout.connect(func(): game_room.close_room())
			else:
				var game_seed = randi()
				game_room.network.start_prep.rpc(game_seed)
	)
