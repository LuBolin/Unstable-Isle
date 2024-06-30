class_name RangerGatling
extends HeroStatus


# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 5
var h_id
var id = "RangerGatling"
var target

func create(hero, d):
	h_id = hero.controller_id
	duration = d

func simulate(hero, state, input):
	var interactions = []
	var delta = get_physics_process_delta_time()
	duration = state["duration"]
	h_id = state["h_id"]
	
	#every 0.2 seconds fire a bullet
	if not input == null:
		target = input.target
	if not target == null:
		if not floor(duration * 5) == floor((duration - delta) * 5):
			RangerAttack.create(hero, target)
	
	duration -= delta
	var node = self
	var parent = get_parent()
	if duration < 0:
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration, "target" : target}
