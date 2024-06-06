class_name CastState
extends HeroState


# Cast at target
var target: Vector2 = Vector2.ZERO
# or
# Cast in direction
var direction: Vector2 = Vector2.ZERO

var spell: SpellList.Spell

var cast_point

func enter():
	pass

func exit():
	cast_point = null
	spell = null

func process_input(event: InputEvent) -> HeroState:
	return null

func clean_up():
	pass


func process_physics(delta: float) -> HeroState:
	cast_point -= delta
	if cast_point <= 0:
		spell.effect.call(hero, target)
		if pending_state:
			return pending_state
		return sm.idle_state

	if pending_state:
		return pending_state
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return null
	if cast_point != null: # currently casting
		return null

	# if on cooldown, go back to previous state
	spell = hero.spell_list.get_spell(input.key)
	if spell:
		cast_point = spell.cast_point
		target = input.target
	return null if spell else sm.prev_state
	
	if input.key == MOUSE_BUTTON_RIGHT:
		return sm.move_state
	return null

func decode(dict: Dictionary):
	target = dict['target']
	spell = hero.spell_list.decode(dict['spell'])
	cast_point = dict['cast_point']
	if cast_point == null and spell:
		cast_point = spell.cast_point
	return self

func serialize():
	return {
		'state_name': 'Cast',
		'target': self.target,
		'spell': spell.name,
		'cast_point': cast_point,
	}
