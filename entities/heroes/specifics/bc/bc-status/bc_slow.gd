class_name BcSlow
extends HeroStatus


# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var h_id
var id = "BcSlow"

func create(hero, d):
	h_id = hero.controller_id
	duration = d

func simulate(hero, state):
	var interactions = []
	var delta = get_physics_process_delta_time()
	duration = state["duration"]
	h_id = state["h_id"]
	hero.modify_speed(1)
	duration -= delta
	if duration < 0:
		interactions.append(func(): queue_free(); print("done"))
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration}
