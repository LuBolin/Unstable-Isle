class_name BlazeChronSpellList
extends SpellList

func _init():
	attack = Spell.new(
		0.1, 1.0, "attack",
		func (hero: Hero, target: Vector2):
			BcAttack.create(hero, target)
			attack.current_cooldown = attack.cooldown
	)
	
	# first spell and attack are same for now
	first_spell = Spell.new(
		1.0, 3.0, "first_spell",
		func (hero: Hero, target: Vector2):
			BcFirst.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	second_spell = Spell.new(
		0.8, 8.0, "second_spell",
		func (hero: Hero, target: Vector2):
			BcFirst.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
	
	ulti_spell = Spell.new(
		1.5, 20.0, "ulti_spell",
		func (hero: Hero, target: Vector2):
			BcFirst.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)

func ret_status(case):
	match case:
		"BcSlow":
			return BcSlow.new()
		"BcStun":
			return BcStun.new()

func ret_projectile(case):
	match case:
		"BcAttack":
			return BcAttack
		"BcFirst":
			return BcFirst
