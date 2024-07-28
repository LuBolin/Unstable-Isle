class_name CosmicDragonCooldowns
extends HeroStatus

# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

var h_id
var id = "CosmicDragonCooldowns"
var cooldowns = {"CosmicDragonBreath" : 0,
				"CosmicDragonFlight" : 0,
				"CosmicDragonWish" : 0,
				"CosmicDragonHaste" : 0
				}

func create(hero, d):
	h_id = hero.controller_id


func simulate(hero, state, input):
	var interactions = []
	h_id = state["h_id"]
	cooldowns = state["cooldowns"]
	var delta = get_physics_process_delta_time()
	
	for cd in cooldowns:
		cooldowns[cd] = max(cooldowns[cd] - delta, 0)
	
	return interactions

func get_state():
	return {"h_id" : h_id, "cooldowns" : cooldowns}
