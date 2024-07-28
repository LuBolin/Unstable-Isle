class_name CosmicDragonSpellList
extends SpellList

# Cosmic Dragon's spells change based on which part he is on. Pressing R cycles through
# Basic attack launches an orb that orbits around Cosmic Dragon
# Head
# Q is Dragon Breath that slows and DoT
# W creates a black hole that pulls things towards it
# Body
# Q pulls orbs in
# W pushes orbs out
# Tail
# Q stuns at the tail
# W grants a temporary speed boost
enum {HEAD, BODY, TAIL}

func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			if not create_part(hero):
				return
			var hero_pos = Vector2(
						hero.global_position.x,
						hero.global_position.z)
			var dirn: Vector2 = target - hero_pos
			CosmicDragonAttack.create(hero, target)
			attack.current_cooldown = attack.cooldown
			var angle = dirn.angle()
			var adjusted = dirn.from_angle(angle + 2 * PI / 3) + hero_pos
			CosmicDragonAttack.create(hero, adjusted)
			adjusted = dirn.from_angle(angle - 2 * PI / 3) + hero_pos
			CosmicDragonAttack.create(hero, adjusted)
	)
	
	first_spell = Spell.new(
		0.01, 0.1, "first_spell",
		func (hero: Hero, target: Vector2):
			if not create_part(hero):
				return
			var current_part = get_part(hero)
			var cooldown = 0
			var cooldowns = get_cooldown(hero)
			match current_part:
				HEAD:
					CosmicDragonBreath.create(hero, target)
					cooldown = 5
					cooldowns["CosmicDragonBreath"] = 5
				BODY:
					#only works because State simulates after Status
					for status in hero.status_manager.get_children():
						if status is CosmicDragonOrbit:
							status.orbs_out = false
				TAIL:
					CosmicDragonWish.create(hero, target)
					cooldown = 6
					cooldowns["CosmicDragonWish"] = 6
			first_spell.current_cooldown = cooldown
	)
	
	second_spell = Spell.new(
		0.01, 0.1, "second_spell",
		func (hero: Hero, target: Vector2):
			if not create_part(hero):
				return
			var current_part = get_part(hero)
			var cooldown = 0
			var cooldowns = get_cooldown(hero)
			match current_part:
				HEAD:
					var cosmic_dragon_flight = CosmicDragonFlight.new()
					cosmic_dragon_flight.create(hero, cosmic_dragon_flight.total_duration)
					hero.apply_status(cosmic_dragon_flight)
					cooldown = 3
					cooldowns["CosmicDragonFlight"] = 3
				BODY:
					#only works because State simulates after Status
					for status in hero.status_manager.get_children():
						if status is CosmicDragonOrbit:
							status.orbs_out = true
				TAIL:
					var cosmic_dragon_haste = CosmicDragonHaste.new()
					cosmic_dragon_haste.create(hero, cosmic_dragon_haste.total_duration)
					hero.apply_status(cosmic_dragon_haste)
					cooldown = 4
					cooldowns["CosmicDragonHaste"] = 4
			second_spell.current_cooldown = cooldown
	)
	
	ulti_spell = Spell.new(
		0.01, 0.1, "ulti_spell",
		func (hero: Hero, target: Vector2):
			if not create_part(hero):
				return
			cycle_part(hero)
			ulti_spell.current_cooldown = ulti_spell.cooldown
			var cooldowns = get_cooldown(hero)
			match get_part(hero):
				HEAD:
					first_spell.current_cooldown = cooldowns["CosmicDragonBreath"]
					second_spell.current_cooldown = cooldowns["CosmicDragonFlight"]
				BODY:
					first_spell.current_cooldown = 0
					second_spell.current_cooldown = 0
				TAIL:
					first_spell.current_cooldown = cooldowns["CosmicDragonWish"]
					second_spell.current_cooldown = cooldowns["CosmicDragonHaste"]
	)


func create_part(hero: Hero):
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			return true
		if child is CosmicDragonTail:
			return true
	CosmicDragonBody.create(hero, Vector2(0, 0))
	CosmicDragonTail.create(hero, Vector2(0, 0))
	var orbit_status = CosmicDragonOrbit.new()
	orbit_status.create(hero, 0)
	hero.apply_status(orbit_status)
	var cooldowns = CosmicDragonCooldowns.new()
	cooldowns.create(hero, 0)
	hero.apply_status(cooldowns)
	attack.current_cooldown = 0.5
	first_spell.current_cooldown = 0.5
	second_spell.current_cooldown = 0.5
	ulti_spell.current_cooldown = 0.5
	return false

#get which part is selected
func get_part(hero: Hero):
	for child in hero.status_manager.get_children():
		if child is CosmicDragonSelection:
			return child.selected
	var cosmic_dragon_selection = CosmicDragonSelection.new()
	cosmic_dragon_selection.create(hero, 0)
	hero.apply_status(cosmic_dragon_selection)
	return cosmic_dragon_selection.selected

func cycle_part(hero: Hero):
	var next = (get_part(hero) + 1) % 3
	for child in hero.status_manager.get_children():
		if child is CosmicDragonSelection:
			child.selected = next
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			child.selected = next == BODY
		if child is CosmicDragonTail:
			child.selected = next == TAIL
	return

func get_cooldown(hero: Hero):
	for child in hero.status_manager.get_children():
		if child is CosmicDragonCooldowns:
			return child.cooldowns

func ret_status(case):
	match case:
		"CosmicDragonOrbit":
			return CosmicDragonOrbit.new()
		"CosmicDragonSelection":
			return CosmicDragonSelection.new()
		"CosmicDragonFlight":
			return CosmicDragonFlight.new()
		"CosmicDragonHaste":
			return CosmicDragonHaste.new()
		"CosmicDragonBreathSlow":
			return CosmicDragonBreathSlow.new()
		"CosmicDragonCooldowns":
			return CosmicDragonCooldowns.new()
	return

func ret_projectile(case):
	match case:
		"CosmicDragonAttack":
			return CosmicDragonAttack
		"CosmicDragonBody":
			return CosmicDragonBody
		"CosmicDragonTail":
			return CosmicDragonTail
		"CosmicDragonWish":
			return CosmicDragonWish
		"CosmicDragonBreath":
			return CosmicDragonBreath
