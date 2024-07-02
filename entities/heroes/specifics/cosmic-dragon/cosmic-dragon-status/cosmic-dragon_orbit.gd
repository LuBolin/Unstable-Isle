class_name CosmicDragonOrbit
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var duration
var total_duration = 0
var h_id
var id = "CosmicDragonOrbit"
var orbit_radius = 100
var orbs_out = false
const max_radius = 300
const min_radius = 100
const radius_speed = 100

func create(hero, d):
	h_id = hero.controller_id
	duration = d

func simulate(hero, state, input):
	var interactions = []
	duration = state["duration"]
	h_id = state["h_id"]
	orbit_radius = state["orbit_radius"]
	orbs_out = state["orbs_out"]
	var delta = get_physics_process_delta_time()
	if orbs_out:
		orbit_radius += delta * radius_speed
	else:
		orbit_radius -= delta * radius_speed
	orbit_radius = max(min(orbit_radius, max_radius), min_radius)
	
	
	return interactions

func get_state():
	return {"h_id" : h_id, "duration" : duration, "orbit_radius" : orbit_radius, \
			"orbs_out" : orbs_out}
