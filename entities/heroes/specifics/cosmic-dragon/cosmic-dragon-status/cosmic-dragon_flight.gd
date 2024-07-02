class_name CosmicDragonFlight
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 5
var h_id
var id = "CosmicDragonFlight"

func create(hero, d):
	h_id = hero.controller_id
	duration = d


func simulate(hero, state, input):
	var interactions = []
	duration = state["duration"]
	h_id = state["h_id"]
	
	var delta = get_physics_process_delta_time()
	hero.state_manager.state_statuses["Flying"] = [duration, total_duration]
	duration -= delta
	if duration < 0:
		var node = self
		var parent = get_parent()
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration}
