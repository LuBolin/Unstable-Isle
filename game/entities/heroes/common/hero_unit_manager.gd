class_name UnitManager
extends Node3D

const PlayerInput = Serializables.PlayerInput

var hero : Hero

func init(h: Hero):
	hero = h

func drop_freed(unit_states: Dictionary):
	for child in get_children():
		if not child.id in unit_states:
			child.queue_free()

func simulate(unit_states, input: PlayerInput):
	var end_states = {}
	for child in get_children():
		if child.id in unit_states:
			var unit_state = unit_states[child.id]
			var end_state = child.simulate(unit_state)
			if end_state:
				end_states[unit_state['id']] = end_state
		else:
			# child.simulate(child.serialize())
			end_states[child.id] = child.serialize()
	return end_states

func serialize():
	var unit_states = {}
	for c in get_children():
		unit_states[c.id] = c.serialize()
	return unit_states

func _physics_process(delta):
	pass

var derivatives_count = 0
