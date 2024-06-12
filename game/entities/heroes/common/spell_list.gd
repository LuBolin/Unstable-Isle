class_name SpellList
extends Resource

var attack: Spell :
	set(v): attack = v; update_spell_list()
var first_spell: Spell :
	set(v): first_spell = v; update_spell_list()
var second_spell: Spell :
	set(v): second_spell = v; update_spell_list()
var ulti_spell: Spell :
	set(v): ulti_spell = v; update_spell_list()

var all_spells: Array[Spell]

func update_spell_list():
	all_spells = [
		attack, first_spell,
		second_spell, ulti_spell
	]

const cast_keys = [
	MOUSE_BUTTON_LEFT, KEY_Q,
	KEY_W, KEY_R
]

func get_spell(input_key: Key):
	var target: Spell
	match input_key:
		MOUSE_BUTTON_LEFT: target = attack
		KEY_Q: target = first_spell
		KEY_W: target = second_spell
		KEY_R: target = ulti_spell
	if target and target.current_cooldown == 0:
		return target
	else:
		return null

# ticked in StateManager.process_physics
func cooldown_tick(delta: float):
	for spell in all_spells:
		if spell: # could be uninitialized
			spell.cooldown_tick(delta)

func decode(spell_name: String):
	var spell: Spell
	match spell_name:
		'attack': spell = attack
		'first_spell': spell = first_spell
		'second_spell': spell = second_spell
		'ulti_spell': spell = ulti_spell
	return spell

class Spell:
	var name
	var cast_point: float
	var cooldown: float
	var current_cooldown: float
	var effect: Callable
	
	func _init(cp: float, cd: float, n: String, ef: Callable):
		cast_point = cp
		cooldown = cd
		current_cooldown = cooldown
		name = n
		effect = ef
	
	func cooldown_tick(delta: float):
		current_cooldown -= delta
		current_cooldown = max(current_cooldown, 0.0)
