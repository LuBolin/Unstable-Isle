class_name StatusManager
extends Node3D

const PlayerInput = Serializables.PlayerInput


var hero : Hero

func init(h: Hero):
	hero = h

func drop_freed(unit_statuses: Dictionary):
	for child in get_children():
		if not child.id in unit_statuses:
			child.queue_free()

func apply_status(status : HeroStatus):
	add_child(status)

func simulate(unit_statuses, input: PlayerInput):
	unit_statuses = unit_statuses["unit_statuses"]
	var interactions = []
	for child in get_children():
		if child.id in unit_statuses:
			var unit_status = unit_statuses[child.id]
			var interaction = child.simulate(hero, unit_status)
			interactions += interaction
			unit_statuses.erase(child.id)
	for id in unit_statuses:
		#super scuffed rn to get smth working
		var entities = hero.get_parent()
		for entity in entities.get_children():
			if entity.controller_id == unit_statuses[id]["h_id"]:
				var status = entity.spell_list.ret_status(id)
				hero.apply_status(status)
				var interaction = status.simulate(hero, unit_statuses[id])
				interactions += interaction
	return interactions

func get_state():
	var end_states = {}
	for child in get_children():
		end_states[child.id] = child.get_state()
	return {"unit_statuses" : end_states}
