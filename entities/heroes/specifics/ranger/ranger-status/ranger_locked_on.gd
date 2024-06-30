class_name RangerLockedOn
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 5
var h_id
var id = "RangerLockedOn"
var target_id

func create(hero, d):
	h_id = hero.controller_id
	duration = d

#init might cause problems
func init(t):
	target_id = t

func simulate(hero, state, input):
	var interactions = []
	var delta = get_physics_process_delta_time()
	duration = state["duration"]
	h_id = state["h_id"]
	target_id = state["target_id"]
	
	for unit in hero.unit_manager.get_children():
		if unit is RangerAttack:
			unit.lock_on = target_id
	
	duration -= delta
	var node = self
	var parent = get_parent()
	if duration < 0:
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration, "target_id" : target_id}
