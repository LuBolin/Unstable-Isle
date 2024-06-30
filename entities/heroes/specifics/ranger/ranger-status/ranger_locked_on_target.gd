class_name RangerLockedOnTarget
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

const arrow = preload("res://entities/heroes/specifics/ranger/ranger-status/ranger_locked_on_target.tscn")

var duration
var total_duration = 5
var h_id
var id = "RangerLockedOnTarget"

func create(hero, d):
	h_id = hero.controller_id
	duration = d

func simulate(hero, state, input):
	var interactions = []
	var delta = get_physics_process_delta_time()
	duration = state["duration"]
	h_id = state["h_id"]
	if len(get_children()) == 0:
		var a = arrow.instantiate()
		add_child(a)
	get_child(0).global_position = hero.global_position
	duration -= delta
	if duration < 0:
		var node = self
		var parent = get_parent()
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration}
