class_name CastState
extends HeroState

# Cast at target
var target: Vector2 = Vector2.ZERO
# or
# Cast in direction
var direction: Vector2 = Vector2.ZERO

func enter():
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func clean_up():
	pass


func process_physics(delta: float) -> HeroState:
	#for now if in state, we just cast bullet
	$Spells.create_bullet(target, input_frame)
	if pending_state:
		return pending_state
	return null

func process_frame(delta: float) -> HeroState:
	return null

var input_frame = 0
func simulate_input(input: PlayerInput):
	if not input:
		return
	if input.key == MOUSE_BUTTON_RIGHT:
		return sm.move_state
	if input.key == 81:
		target = input.target
		input_frame = input.frame

func decode(dict: Dictionary):
	target = dict['target']
	return self

func serialize():
	return {
		'state_name': 'Cast',
		'target': self.target,
	}
