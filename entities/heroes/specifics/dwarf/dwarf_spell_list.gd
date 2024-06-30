class_name DwarfSpellList
extends SpellList

func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			DwarfMelee.create(hero, target)
			attack.current_cooldown = attack.cooldown
	)
	
	# first spell and attack are same for now
	first_spell = Spell.new(
		0.5, 3.0, "first_spell",
		func (hero: Hero, target: Vector2):
			var delay = 0.15
			var offset = 20
			var tree = hero.get_tree()
			for i in range(3):
				tree.create_timer(i * delay).timeout.connect(
					func(): DwarfMelee.create(hero, target, i * offset))
			DwarfMelee.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	second_spell = Spell.new(
		0.1, 7.0, "second_spell",
		func (hero: Hero, target: Vector2):
			DwarfBomb.create(hero, target)
			second_spell.current_cooldown = second_spell.cooldown
	)
	
	ulti_spell = Spell.new(
		1.0, 10.0, "ulti_spell",
		func (hero: Hero, target: Vector2):
			DwarfWall.create(hero, target)
			ulti_spell.current_cooldown = ulti_spell.cooldown
	)

func ret_status(case):
	match case:
		"DwarfWallStun":
			return DwarfWallStun.new()
	return

func ret_projectile(case):
	match case:
		"DwarfMelee":
			return DwarfMelee
		"DwarfBomb":
			return DwarfBomb
		"DwarfWall":
			return DwarfWall
