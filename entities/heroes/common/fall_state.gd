class_name FallState
extends HeroState

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const FALL_TIME: float = 5.0
var fall_countdown: float

func enter():
	fall_countdown = FALL_TIME

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	hero.velocity.y -= gravity * delta
	hero.move_and_slide()
	
	fall_countdown -= delta
	if fall_countdown <= 0:
		return sm.death_state
	
	if hero.interrupted:
		hero.interrupted = false
		return null
	if hero.is_on_floor():
		if pending_state:
			return pending_state
		else:
			return sm.idle_state
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	return null

func decode(dict: Dictionary):
	return self

func serialize():
	return {
		'state_name': 'Fall',
		'fall_velocity': hero.velocity.y
	}
