extends Node3D

@onready var player_node = preload("res://entities/heroes/base_hero.tscn")

# saves last X frames
# buffer 0.1 seconds, 60fps -> 6 physics frames
# 5 poll per frame -> 30 buffer frames
const BUFFER_SIZE = 30
var buffer: Array[FrameState] = []
var current_frame: int = 0

@onready var arena: ArenaController = $Arena
@onready var menu_overlay = $"../GUI/MenuOverlay"
@onready var hero_picker = $"../GUI/HeroPicker"


enum PHASE{
	HOLD,
	PREP,
	GAME
}

var game_phase: PHASE = PHASE.HOLD

func _ready():
	Network.start_prep_signal.connect(start_prep)
	Network.start_game_signal.connect(start_game)
	Network.pick_hero_signal.connect(pick_hero)
	Network.receive_server_frame.connect(receive_truth)
	Network.receive_client_input.connect(receive_input)

var hero_choices = {}

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_P:
				print(game_phase)

func start_prep(island_seed):
	if game_phase == PHASE.PREP:
		return
	game_phase = PHASE.PREP
	print("Prepping " + str(multiplayer.get_unique_id()))
	menu_overlay.set_visible(false)
	if(multiplayer.is_server()):
		Network.start_prep.rpc(island_seed)
	else:
		hero_picker.set_visible(true)
	for p in Network.player_list:
		hero_choices[p] = null
	arena.init_island(island_seed)

func start_game():
	if game_phase == PHASE.GAME:
		return
	game_phase = PHASE.GAME
	hero_picker.set_visible(false)
	print("Starting " + str(multiplayer.get_unique_id()))
	var start_states = {} # dict of player states
	var start_inputs = {} # empty
	if(multiplayer.is_server()):
		Network.start_game.rpc()
	
	# radius is 400
	var distance_from_center = Settings.SPAWN_RADIUS_PERCENT * Settings.ISLAND_RADIUS
	var angle_increment = 2.0 * PI / len(Network.player_list)
	
	for i in Network.player_list:
		var angle = i * angle_increment
		var x = distance_from_center * cos(angle)
		var z = distance_from_center * sin(angle)
		var safety_y = 5
		var pos = Vector3(x, safety_y, z)
		var name = hero_choices[i]
		start_states[i] = create_player(i, name, pos)
		print("Creating player: " + str(i))
	buffer.append(FrameState.new(0, start_states, start_inputs))
	print("Started " + str(multiplayer.get_unique_id()))
	arena.start_game()

func pick_hero(hero: String, id):
	if game_phase != PHASE.PREP:
		return
	print("%s picking %s" % [id, hero])
	print("Choices before: ")
	print(hero_choices)
	if id in hero_choices:
		if hero_choices[id] == null:
			hero_choices[id] = hero
			Network.pick_hero.rpc(hero, id)
	var all_picked = true
	for p_id in hero_choices:
		if hero_choices[p_id] == null:
			all_picked = false
			break
	if all_picked:
		Network.start_game_signal.emit()
	print("Choices after: ")
	print(hero_choices)

## Actual game loop
func _physics_process(delta):
	if game_phase != PHASE.GAME:
		return
	
	if (buffer.size() > BUFFER_SIZE):
		buffer.pop_front()
	
	current_frame += 1
	var new_frame_state = _simulate_frame(buffer[-1])
	buffer.append(new_frame_state)
	if (multiplayer.is_server()):
		if current_frame in future_inputs:
			print(future_inputs[current_frame])
			for i in future_inputs[current_frame]:
				receive_input(i[0], i[1])
			future_inputs.erase(current_frame)
		Network.send_frame.rpc(new_frame_state.serialize())
	else: # is client
		var batch = Network.POLL_PER_FRAME
		for i in range(batch):
			get_tree().create_timer(i*delta/batch)\
				.timeout.connect(poll_and_send)


var future_inputs = {}

func receive_input(input: Dictionary, id):
	print("Received input: %s %s" % [input['frame'], input['target']])
	if input['frame'] > current_frame:
		print(future_inputs)
		if input['frame'] in future_inputs:
			if not [input, id] in future_inputs[input['frame']]:
				future_inputs[input['frame']].append([input, id])
		else:
			future_inputs[input['frame']] = [[input, id]]
		print("Rejected. input %s, current %s" % [input['frame'], current_frame])
		# ahead, wrong.
		return
	elif input['frame'] < buffer[0]['frame']:
		print("Rejected. input %s, current %s" % [input['frame'], buffer[0]['frame']])
		# too old
		return
	# frames[10,11,12,13,14]
	# buffer = 5
	# current = 14
	# input is at 11
	for i in range(len(buffer)):
		var fs = buffer[i]
		if fs['frame'] == input['frame']:
			# duplicate
			if id in fs['inputs'] and fs['inputs'][id] == input:
				return
			print("Processing input: %s %s" % [input['frame'], input['target']])
			fs['inputs'][id] = input
			receive_truth(buffer[i].serialize())
			return


# tolerate being up to 1/2 of buffer ahead of servcer
const LEAD_TOLERANCE = BUFFER_SIZE * 0.5
# absolute truth
# if frame time within buffer, resimulate from there
# else clear buffer and insert frame
func receive_truth(fs_dict: Dictionary):
	var fs = FrameState.new(fs_dict['frame'], fs_dict['states'], fs_dict['inputs'])
	# if frame ahead of local, receive without simulating
	# basically simulate only up to most recent
	if fs['frame'] > current_frame:
		current_frame = fs['frame']
		state_update(fs['states'], {})
		buffer = [fs]
		return
	# somehow too far ahead
	elif fs['frame'] < current_frame - LEAD_TOLERANCE:
		current_frame = fs['frame']
		state_update(fs['states'], {})
		buffer = [fs]
		return
	#print("I am %s. Received truth frame of %s while current is %s. Frames is of size %s"\
		 #% [multiplayer.get_unique_id(), fs_dict['frame'], current_frame, len(buffer)])
	# print("Receiving frame: %s" % [frame])
	var truth_frame = fs['frame']
	var index = 0
	while index < len(buffer):
		var f = buffer[index]
		if f['frame'] < truth_frame:
			index += 1
		elif f['frame'] == truth_frame:
			break
	
	buffer[index] = fs
	for i in range(index, len(buffer)-1):
		var cur_fs = buffer[i]
		var next_inputs = buffer[i+1].inputs
		var next_fs = _simulate_frame(cur_fs)
		next_fs.inputs = next_inputs
		buffer[i+1] = next_fs

func _simulate_frame(fs: FrameState) -> FrameState:
	var new_frame = fs['frame'] + 1
	var new_fs = state_update(fs['states'], fs['inputs'])
	return FrameState.new(new_frame, new_fs, {})

## Given states and inputs, updates state of all children and returns state array
func state_update(states, inputs):
	for child in $Entities.get_children():
		var id = child.controller_id
		if id in states:
			var input = {}
			if id in inputs:
				input = inputs[id]
			states[id] = child.simulate(states[id], input)
	return states


# #################################
# Non-logic functions
# #################################

const MAKE_SURE = 10
func poll_and_send():
	var last_input = InputPoller.poll_game_input(current_frame)
	if last_input.is_empty():
		return
	buffer[buffer.size() - 1].inputs[multiplayer.get_unique_id()] = last_input
	for i in range(MAKE_SURE):
		Network.send_input.rpc_id(1, last_input)

func create_player(id, name, pos):
	var player = player_node.instantiate()
	var init_state = player.create(id, name, pos)
	$Entities.add_child(player)
	return init_state


class FrameState:
	var frame = 0
	# dict of state of each entity
	# everything stored is serialized
	var states = {}
	# dict of state of each player's input using id
	# everything stored is serialized
	var inputs = {}
	func _init(f, s, i):
		frame = f
		states = s
		inputs = i
	func serialize():
		return {
			"frame" : frame,
			"states" : states,
			"inputs" : inputs
		}
