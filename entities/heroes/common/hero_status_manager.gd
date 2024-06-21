extends Node3D

const PlayerInput = Serializables.PlayerInput

func drop_freed(unit_statuses: Dictionary):
	for child in get_children():
		if not child.id in unit_statuses:
			child.queue_free()

func simulate(unit_statuses, input: PlayerInput):
	unit_statuses = unit_statuses["unit_statuses"]
	var interactions = []
	for child in get_children():
		if child.id in unit_statuses:
			var unit_status = unit_statuses[child.id]
			var interaction = child.simulate(unit_status)
			interactions += interaction
	return interactions
