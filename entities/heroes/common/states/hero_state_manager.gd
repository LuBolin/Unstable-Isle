class_name StateManager
extends Node3D

const PlayerState = Serializables.PlayerState
const PlayerInput = Serializables.PlayerInput

# @onready var hero: Hero = $".."
var hero: Hero
@export var starting_state: HeroState

@export var idle_state: HeroState
@export var move_state: HeroState
@export var fall_state: HeroState
@export var cast_state: HeroState
@export var death_state: HeroState

var pending_state: HeroState
var pending_input: PlayerInput
#var prev_state: HeroState
var current_state: HeroState

var status_label: Label3D

func init(_hero: Hero):
	hero = _hero
	Serializables.state_managers[hero.controller_id] = self
	for child in get_children():
		if not (child is HeroState):
			continue
		child.hero = hero
		child.sm = self
	change_state(starting_state)
	status_label = hero.status_label

#State-tied statuses
#Statuses are Stunned, Rooted, Silenced for now
var state_statuses = {}
func clean_up():
	state_statuses = {}

func change_state(new_state: HeroState):
	# server updates client state
	if current_state == new_state:
		return
	
	
	if current_state:
		current_state.exit()

	#prev_state = current_state
	current_state = new_state
	current_state.enter()
	$StateLabel.set_text(current_state.name)

func queue_pending_state(p_state: HeroState):
	pending_state = p_state

#Currently does nothing (none of the states have process_input)
func _input(event):
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func _physics_process(delta):
	#hero.spell_list.cooldown_tick(delta)
	#var new_state = current_state.process_physics(delta)
	#if new_state:
		#change_state(new_state)
	pass

func _process(delta):
	# graphical simulations
	# such as target line
	current_state.process_frame(delta)
	#var new_state = 
	#if new_state:
	#	change_state(new_state)
	$"../StatusLabel".apply_status(state_statuses)

func simulate(hs: HeroState, input: PlayerInput):
	# current_state.reset() ?
	change_state(hs)
	# current_state = hs

	# arbituary non-null value
	var new_state = 1
	# a loop is required
	# right click change idle to move
	# move then need to process right click to set target
	# if state does not change in simulate_input,
	# new_state will be null, and we continue
	var visited = []
	while new_state:
		visited.append(current_state)
		new_state = current_state.simulate_input(input)
		if new_state:
			change_state(new_state)
			# transition back, and end simulate input
			if new_state in visited:
				break
		else:
			pending_state = simulate_input(input)
			pending_input = input
	if current_state == idle_state and not pending_state == null:
		change_state(pending_state)
		input = pending_input
		current_state.simulate_input(input)
		pending_state = null
		pending_input = null
		#currently cast_state having issues with not being initialised
	
	hs.clean_up()
	# TODO: simulate statuses
	
	
	var delta = get_physics_process_delta_time()
	hero.spell_list.cooldown_tick(delta)
	#new_state = current_state.process_physics(delta)
	#if new_state:
	#	change_state(new_state)
	var interactions = []
	var state_interactions = current_state.process_physics(delta)
	interactions += state_interactions
	return interactions

func simulate_input(input: PlayerInput):
	if not input:
		return null

	if input.key in SpellList.cast_keys:
		return cast_state
	
	if input.key == MOUSE_BUTTON_RIGHT:
		return move_state

	return null

func decode(hs_state: Dictionary) -> HeroState:
	var state_name = hs_state['state_name']
	return get_node(state_name).decode(hs_state)
