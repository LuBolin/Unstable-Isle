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
	unit_states = unit_states["unit_states"]
	var interactions = []
	for child in get_children():
		if child.id in unit_states and child.type == unit_states[child.id]["type"]: #pls work
			var unit_state = unit_states[child.id]
			var interaction = child.simulate(unit_state)
			unit_states.erase(child.id)
			interactions += interaction
	for id in unit_states:
		var unit_state = unit_states[id]
		var unit = hero.spell_list.ret_projectile(unit_state["type"]).create(hero, unit_state["direction"])
		unit.id = id
		var interaction = unit.simulate(unit_state)
		interactions += interaction
	return interactions


func _physics_process(delta):
	pass

var derivatives_count = 0

func add(unit):
	add_child(unit)
	derivatives_count += 1
	return derivatives_count - 1

func get_state():
	var end_states = {}
	for child in get_children():
		end_states[child.id] = child.get_state()
	return {"d_count" : derivatives_count, "unit_states" : end_states}
