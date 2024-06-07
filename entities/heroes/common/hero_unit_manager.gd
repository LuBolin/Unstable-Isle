class_name UnitManager
extends Node3D

const PlayerInput = Serializables.PlayerInput

func drop_freed(unit_states: Dictionary):
	for child in get_children():
		if not child.id in unit_states:
			child.queue_free()

func simulate(unit_states, input: PlayerInput):
	derivatives_count = unit_states["d_count"]
	unit_states = unit_states["unit_states"]
	drop_freed(unit_states)
	var interactions = []
	for child in get_children():
		if child.id in unit_states:
			var unit_state = unit_states[child.id]
			var simulate_interaction = child.simulate(unit_state)
			interactions.append(simulate_interaction)
	return interactions

func _physics_process(delta):
	pass

var derivatives_count = 0

func get_state():
	var end_states = {}
	for child in get_children():
		end_states[child.id] = child.get_state()
	return {"d_count" : derivatives_count, "unit_states" : end_states}
