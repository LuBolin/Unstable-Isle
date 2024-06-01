class_name IdleState
extends HeroState

func enter():
	hero.velocity = Vector3.ZERO
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	if hero.interrupted:
		hero.interrupted = false
		return null
	
	hero.move_and_slide() # force is_on_floor to update
	var airborne = not hero.is_on_floor()
	if airborne:
		return sm.fall_state
	if pending_state:
		return pending_state
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return
	if input.key == MOUSE_BUTTON_RIGHT:
		return sm.move_state
	if input.key == 81:
		return sm.cast_state

func decode(dict: Dictionary):
	return self

func serialize():
	return {'state_name': 'Idle'}
