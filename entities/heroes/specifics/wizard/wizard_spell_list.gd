class_name WizardSpellList
extends SpellList

func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			WizardAttack.create(hero, target)
			attack.current_cooldown = attack.cooldown
	)
	
	first_spell = Spell.new(
		0.05, 4.0, "first_spell",
		func (hero: Hero, target: Vector2):
			WizardSkyStrike.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	second_spell = Spell.new(
		0.8, 10.0, "second_spell",
		func (hero: Hero, target: Vector2):
			WizardStormCloud.create(hero, target)
			second_spell.current_cooldown = second_spell.cooldown
	)
	
	ulti_spell = Spell.new(
		1.0, 15.0, "ulti_spell",
		func (hero: Hero, target: Vector2):
			var delay = 0.2
			var offset = 48
			var tree = hero.get_tree()
			var hero_pos = hero.global_position
			var hero_pos_v2 = Vector2(hero_pos.x, hero_pos.z)
			var dirn = target - hero_pos_v2
			dirn = dirn.normalized()
			for i in range(5):
				tree.create_timer(i * delay).timeout.connect(
					func():
						WizardSkyStrike.create(hero, \
							hero_pos_v2 + (i + 1) * dirn * offset))
			ulti_spell.current_cooldown = ulti_spell.cooldown
	)

func ret_status(case):
	return null
	#match case:
		#"RangerLockedOn":
			#return RangerLockedOn.new()
		#"RangerGatling":
			#return RangerGatling.new()
		#"RangerLockedOnTarget":
			#return RangerLockedOnTarget.new()

func ret_projectile(case):
	match case:
		"WizardAttack":
			return WizardAttack
		"WizardSkyStrike":
			return WizardSkyStrike
		"WizardStormcloud":
			return WizardStormCloud
