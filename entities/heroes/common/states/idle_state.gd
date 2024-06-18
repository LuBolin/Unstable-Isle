class_name IdleState
extends HeroState

func enter():
	hero.velocity = Vector3.ZERO
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> Array:
	if hero.interrupted:
		hero.interrupted = false
		return []
	
	hero.move_and_slide() # force is_on_floor to update
	var airborne = not hero.is_on_floor()
	if airborne:
		return [func(): sm.change_state(sm.fall_state)]
	if pending_state:
		return [func(): sm.change_state(pending_state)]
	return []

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return

	if input.key in SpellList.cast_keys:
		return sm.cast_state
	
	if input.key == MOUSE_BUTTON_RIGHT:
		return sm.move_state

func decode(dict: Dictionary):
	return self

func serialize():
	return {'state_name': 'Idle'}
