class_name DeathState
extends HeroState

func enter():
	print("%s died!" % [hero.name])
	Round.hero_died.emit(hero.controller_id)
	hero.hide()

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
		'state_name': 'Death'
	}
