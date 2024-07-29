class_name DeathState
extends HeroState

func enter():
	# print("%s died!" % [hero.name])
	hero.game_room.round.hero_died.emit(hero.controller_id)
	hero.hide()
	hero.global_position.y = Settings.KILL_HEIGHT

func exit():
	hero.show()

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> Array:
	return []

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
