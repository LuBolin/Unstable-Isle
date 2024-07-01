class_name CosmicDragonSelection
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 0
var h_id
var id = "CosmicDragonSelection"
var selected = 0 #enum 0 head 1 body 2 tail

func create(hero, d):
	h_id = hero.controller_id
	duration = d


func simulate(hero, state, input):
	var interactions = []
	duration = state["duration"]
	h_id = state["h_id"]
	selected = state["selected"]
	
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration, "selected" : selected}
