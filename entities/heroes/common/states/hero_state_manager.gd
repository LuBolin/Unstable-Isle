class_name StateManager
extends Node3D

const PlayerState = Serializables.PlayerState
const PlayerInput = Serializables.PlayerInput

@export var starting_state: HeroState
@onready var hero: Hero = $".."

var current_state: HeroState

func init(hero: Hero):
	Serializables.state_managers[hero.controller_id] = self
	for child in get_children():
		if not (child is HeroState):
			continue
		child.hero = hero
	change_state(starting_state)

func change_state(new_state: HeroState):
	# server updates client state
	if current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
	$HealthLabel.set_text(current_state.name)

func _input(event):
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func _physics_process(delta):
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func _process(delta):
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func simulate(hs: HeroState, input: PlayerInput):
	# current_state.reset() ?
	change_state(hs)
	# current_state = hs
	
	# TODO: simulate statuses
	
	# arbituary non-null value
	var new_state = 1
	# a loop is required
	# right click change idle to move
	# move then need to process right click to set target
	# if state does not change in simulate_input,
	# new_state will be null, and we continue
	while new_state:
		new_state = current_state.simulate_input(input)
		if new_state:
			change_state(new_state)
	
	var delta = get_physics_process_delta_time()
	new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func decode(hs_state: Dictionary) -> HeroState:
	var state_name = hs_state['state_name']
	return get_node(state_name).decode(hs_state)
