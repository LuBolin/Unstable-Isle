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
		0.5, 3.0, "first_spell",
		func (hero: Hero, target: Vector2):
			BcFirst.create(hero, target)
			first_spell.current_cooldown = first_spell.cooldown
	)
