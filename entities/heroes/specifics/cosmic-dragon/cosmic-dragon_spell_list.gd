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


func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			CosmicDragonAttack.create(hero, target)
			attack.current_cooldown = attack.cooldown
	)
	
	first_spell = Spell.new(
		0.0, 3.0, "first_spell",
		func (hero: Hero, target: Vector2):
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	second_spell = Spell.new(
		0.0, 7.0, "second_spell",
		func (hero: Hero, target: Vector2):
			second_spell.current_cooldown = second_spell.cooldown
	)
	
	ulti_spell = Spell.new(
		0.0, 0.1, "ulti_spell",
		func (hero: Hero, target: Vector2):
			cycle_part(hero)
			ulti_spell.current_cooldown = ulti_spell.cooldown
	)

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
	var exist = false
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			exist = true
			child.selected = next == 1
		if child is CosmicDragonTail:
			exist = true
			child.selected = next == 2
	if not exist:
		CosmicDragonBody.create(hero, Vector2(0, 0))
		CosmicDragonTail.create(hero, Vector2(0, 0))
	return

func ret_status(case):
	match case:
		"CosmicDragonOrbit":
			return CosmicDragonOrbit.new()
		"CosmicDragonSelection":
			return CosmicDragonSelection.new()
	return

func ret_projectile(case):
	match case:
		"CosmicDragonAttack":
			return CosmicDragonAttack
		"CosmicDragonBody":
			return CosmicDragonBody
		"CosmicDragonTail":
			return CosmicDragonTail
