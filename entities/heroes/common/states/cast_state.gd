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


func process_physics(delta: float) -> Array:
	var interactions = []
	if hero.health <= 0:
		return [func(): sm.change_state(sm.death_state)]
		
	cast_point -= delta
	if "Stunned" in sm.state_statuses or "Silenced" in sm.state_statuses:
		cast_point = spell.cast_point
	
	if cast_point <= 0:
		spell.effect.call(hero, target)
		#interactions.append(func(): spell.effect.call(hero, target))
		if pending_state:
			interactions.append(func(): sm.change_state(pending_state))
			return interactions
		interactions.append(func(): sm.change_state(sm.idle_state))
		return interactions

	if pending_state:
		interactions.append(func(): sm.change_state(pending_state))
		return interactions
	return interactions

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
	#what the idk the syntax below so
	return null if spell else null #used to be sm.prev_state
	
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
