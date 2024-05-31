class_name IdleState
extends HeroState

@export var move_state: HeroState

func enter():
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	if hero.interrupted:
		hero.interrupted = false
	else:
		if pending_state:
			return pending_state
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return
	if input.key == MOUSE_BUTTON_RIGHT:
		return move_state

func decode(dict: Dictionary):
	return self

func serialize():
	return {'state_name': 'Idle'}
