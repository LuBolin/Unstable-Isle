class_name CastState
extends HeroState

func enter():
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	return null

func decode(dict: Dictionary):
	return self

func serialize():
	return {
		'state_name': 'Cast'
	}
