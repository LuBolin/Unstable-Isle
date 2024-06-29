class_name GameController
extends Node3D

const FrameState = Serializables.FrameState
const PlayerInput = Serializables.PlayerInput
const PlayerState = Serializables.PlayerState
const GameState = Serializables.GameState
const ArenaState = Serializables.ArenaState

# @onready var player_node = preload("res://game/entities/heroes/common/base_hero.tscn")
var player_node = load("res://game/entities/heroes/common/base_hero.tscn")

const PHASE = game_room.PHASE

# saves last X frames
# buffer 0.1 seconds, 60fps -> 6 physics frames
# 5 poll per frame -> 30 buffer frames
const BUFFER_SIZE = 30
var buffer: Array[FrameState] = []
var current_frame: int = 0

var game_room: GameRoom:
	get: game_room = game_room if game_room else get_node(".."); return game_room
@onready var entities = $Entities
@onready var arena: ArenaController = $Arena


func _ready():
	game_room.round.prep_started.connect(start_prep)
	game_room.round.hero_picked.connect(pick_hero)
	game_room.round.round_started.connect(start_round)
	game_room.round.received_server_frame.connect(receive_truth)
	game_room.round.received_client_input.connect(receive_input)

func _input(event):
	if game_room.game_phase != PHASE.GAME:
		return
	## trigger hits on server side
	## for ground_chunk debugging
	#if multiplayer.is_server() \
		#and event.is_pressed() \
		#and event is InputEventMouseButton \
		#and event.button_index == MOUSE_BUTTON_LEFT:
		#
		#var mousePos = get_viewport().get_mouse_position()
		#var camera_3d = get_viewport().get_camera_3d()
		#var from = camera_3d.project_ray_origin(mousePos)
		#var to = from + camera_3d.project_ray_normal(mousePos) * 1000
		#var space = get_world_3d().direct_space_state
		#var rayQuery = PhysicsRayQueryParameters3D.new()
		#rayQuery.from = from
		#rayQuery.to = to
		#var result = space.intersect_ray(rayQuery)
		#if not result.is_empty():
			#var chunk = result['collider']
			## collider is already the rigidbody
			#if chunk is GroundChunk:
				#chunk.hit()

func start_prep(island_seed):
	if game_room.game_phase == PHASE.PREP:
		return
	game_room.game_phase = PHASE.PREP
	print("Prep started on ", game_room.multiplayer.get_unique_id())
	# print("Prepping " + str(multiplayer.get_unique_id()))
	if(game_room.mutiplayer.is_server()):
		game_room.network.start_prep.rpc(island_seed)
	arena.init_island(island_seed)
	game_room.round.reset()
	for child in entities.get_children(): child.queue_free()
	current_frame = 0
	buffer.clear()

func start_round():
	if game_room.game_phase == PHASE.GAME:
		return
	game_room.game_phase = PHASE.GAME
	print("Starting " + str(game_room.mutiplayer.get_unique_id()))
	if(game_room.mutiplayer.is_server()):
		game_room.network.start_round.rpc()
	
	# radius is 400
	var distance_from_center = Settings.SPAWN_RADIUS_PERCENT * Settings.ISLAND_RADIUS
	var angle_increment = 2.0 * PI / len(game_room.players)
	
	var players = {}
	var spawn_count = 0
	for id in game_room.players:
		var angle = spawn_count * angle_increment
		var x = distance_from_center * cos(angle)
		var z = distance_from_center * sin(angle)
		var safety_y = 5
		# to be updated in team mode
		# for teams to spawn near each other
		var spawn_position = Vector3(x, safety_y, z)
		var hero_name = game_room.round.hero_choices[id]
		players[id] = create_player(id, hero_name, spawn_position)
		spawn_count += 1
	var arena_state: ArenaState = ArenaState.new(arena.chunk_states)
	var start_states: GameState = GameState.new(arena_state, players)
	var start_inputs = {} # empty dict of PlayerInput
	buffer.append(FrameState.new(0, start_states, start_inputs))
	# print("Client at init: ",buffer[0].states.players.values()[0].hero_state)
	print("Started " + str(game_room.mutiplayer.get_unique_id()))
	arena.start_round()

func pick_hero(hero: String, id):
	if game_room.game_phase != PHASE.PREP:
		return
	if id in game_room.round.hero_choices:
		# if game_room.round.hero_choices[id] == null:
		game_room.round.hero_choices[id] = hero
		if game_room.mutiplayer.is_server():
			game_room.network.pick_hero.rpc(hero, id)
	var all_picked = true
	for p_id in game_room.round.hero_choices:
		if game_room.round.hero_choices[p_id] == null:
			all_picked = false
			break
	if all_picked:
		game_room.round.round_started.emit()


## Actual game loop
func _physics_process(delta):
	if game_room.game_phase != PHASE.GAME:
		return
	
	if (buffer.size() > BUFFER_SIZE):
		buffer.pop_front()
	
	current_frame += 1
	var arena_chunk_states = arena.chunk_states
	var new_frame_state: FrameState = _simulate_frame(buffer[-1])
	new_frame_state.states.arena.chunks = arena_chunk_states
	buffer.append(new_frame_state)
	if (game_room.mutiplayer.is_server()):
		if current_frame in future_inputs:
			for i in future_inputs[current_frame]:
				# re-serialize, since receive_input
				# normally handles input from rpc
				receive_input(i[0].serialize(), i[1])
			future_inputs.erase(current_frame)
		game_room.network.send_frame.rpc(new_frame_state.serialize())

	else: # is client
		var batch = Settings.POLL_PER_FRAME
		for i in range(batch):
			get_tree().create_timer(i*delta/batch)\
				.timeout.connect(poll_and_send)

var future_inputs = {}
func receive_input(input_dict: Dictionary, id):
	var input: PlayerInput = PlayerInput.decode(input_dict)
	# print("Received input: %s %s" % [input.frame, input.target])
	if input.frame > current_frame:
		if input.frame in future_inputs:
			if not [input, id] in future_inputs[input.frame]:
				future_inputs[input.frame].append([input, id])
		else:
			future_inputs[input.frame] = [[input, id]]
		# print("Rejected. input %s, current %s" % [input.frame, current_frame])
		# ahead, wrong.
		return
	elif input.frame < buffer[0].frame:
		print("Rejected. input %s, current %s" % [input.frame, buffer[0].frame])
		# too old
		return
	# frames[10,11,12,13,14]
	# buffer = 5
	# current = 14
	# input is at 11
	for i in range(len(buffer)):
		#we modify buffer in receive_truth which might cause an out of bounds error
		if i >= len(buffer):
			continue
		var fs = buffer[i]
		if fs.frame == input.frame:
			# duplicate
			if id in fs.inputs and fs.inputs[id].serialize() == input.serialize():
				return
			fs.inputs[id] = input
			receive_truth(buffer[i].serialize())

# tolerate being up to 1/2 of buffer ahead of servcer
const LEAD_TOLERANCE = BUFFER_SIZE * 0.5
# absolute truth
# if frame time within buffer, resimulate from there
# else clear buffer and insert frame
func receive_truth(fs_dict: Dictionary):
	var fs: FrameState = FrameState.decode(fs_dict)
	# if frame ahead of local, receive without simulating
	# basically simulate only up to most recent
	if fs.frame > current_frame:
		current_frame = fs.frame
		state_update(fs.states, {})
		buffer = [fs]
		return
	# somehow too far ahead
	elif fs.frame < current_frame - LEAD_TOLERANCE:
		current_frame = fs.frame
		state_update(fs.states, {})
		buffer = [fs]
		return
	var truth_frame = fs.frame
	var index = 0
	while index < len(buffer):
		var f = buffer[index]
		if f.frame < truth_frame:
			index += 1
		elif f.frame == truth_frame:
			break
	
	buffer[index] = fs
	for i in range(index, len(buffer)-1):
		var cur_fs: FrameState = buffer[i]
		var next_inputs = buffer[i+1].inputs
		var next_fs = _simulate_frame(cur_fs)
		next_fs.inputs = next_inputs
		buffer[i+1] = next_fs

func _simulate_frame(fs: FrameState) -> FrameState:
	var new_frame = fs['frame'] + 1
	var new_fs = state_update(fs['states'], fs['inputs'])
	return FrameState.new(new_frame, new_fs, {})

## Given states and inputs, updates state of all children and returns state array
func state_update(states: GameState, inputs: Dictionary):
	var interactions = []
	for child : Hero in entities.get_children():
		var id = child.controller_id
		if id in states.players:
			var input: PlayerInput = null
			if id in inputs:
				input = inputs[id]
			# print(states.players, " ", states.players[id])
			var interaction = child.simulate(states.players[id], input)
			interactions += interaction
	
	#the interactions
	#print("Frame: ", current_frame)
	for interaction in interactions:
		interaction.call()
	
	for child : Hero in entities.get_children():
		var id = child.controller_id
		if id in states.players:
			states.players[id] = child.get_state()
	
	arena.update_state(states.arena)
	return states


# #################################
# Non-logic functions
# #################################

const MAKE_SURE = 10
func poll_and_send():
	var last_input: PlayerInput = game_room.poller.poll_game_input(current_frame)
	if not last_input:
		return
	buffer[buffer.size() - 1].inputs[game_room.mutiplayer.get_unique_id()] = last_input
	for i in range(MAKE_SURE):
		game_room.network.send_input.rpc_id(1, last_input.serialize())

func create_player(id, player_name, pos):
	var is_self = game_room.network.multiplayer.get_unique_id() == id
	var player: Hero = Hero.create(id, player_name, pos, is_self, game_room)
	player.hero_died.connect(
		func(id): game_room.round.hero_died.emit(id))
	var init_state = player.get_state()
	entities.add_child(player)
	if is_self:
		game_room.gui.hero_info_hud.set_hero(player)
	return init_state
