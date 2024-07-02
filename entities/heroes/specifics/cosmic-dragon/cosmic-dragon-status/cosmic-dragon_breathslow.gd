class_name CosmicDragonBreathSlow
extends HeroStatus


# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 3
var h_id
var id = "CosmicDragonBreathSlow"

func create(hero, d):
	h_id = hero.controller_id
	duration = d

func simulate(hero, state, input):
	var interactions = []
	var delta = get_physics_process_delta_time()
	duration = state["duration"]
	h_id = state["h_id"]
	hero.modify_speed(0.5)
	duration -= delta
	var node = self
	var parent = get_parent()
	if not floor(duration) == floor((duration - delta)):
		interactions.append(func(): hero.health -= 1)
	if duration < 0:
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration}
