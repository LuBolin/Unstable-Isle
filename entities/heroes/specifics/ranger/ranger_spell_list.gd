class_name RangerSpellList
extends SpellList

func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			RangerAttack.create(hero, target)
			attack.current_cooldown = attack.cooldown
	)
	
	first_spell = Spell.new(
		1.0, 1.0, "first_spell",
		func (hero: Hero, target: Vector2):
			RangerLockOn.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	second_spell = Spell.new(
		0.8, 1.0, "second_spell",
		func (hero: Hero, target: Vector2):
			var hero_pos = Vector2(
						hero.global_position.x,
						hero.global_position.z)
			var dirn: Vector2 = target - hero_pos
			RangerAttack.create(hero, target)
			var angle = dirn.angle()
			var adjusted = dirn.from_angle(angle + PI / 4) + hero_pos
			RangerAttack.create(hero, adjusted)
			adjusted = dirn.from_angle(angle - PI / 4) + hero_pos
			RangerAttack.create(hero, adjusted)
			second_spell.current_cooldown = second_spell.cooldown
	)
	
	ulti_spell = Spell.new(
		1.5, 5.0, "ulti_spell",
		func (hero: Hero, target: Vector2):
			var gatling = RangerGatling.new()
			gatling.create(hero, gatling.total_duration, target)
			hero.apply_status(gatling)
			ulti_spell.current_cooldown = ulti_spell.cooldown
	)

func ret_status(case):
	match case:
		"RangerLockedOn":
			return RangerLockedOn.new()
		"RangerGatling":
			return RangerGatling.new()
		"RangerLockedOnTarget":
			return RangerLockedOnTarget.new()

func ret_projectile(case):
	match case:
		"RangerAttack":
			return RangerAttack
		"RangerLockOn":
			return RangerLockOn
