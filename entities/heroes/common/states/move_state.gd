class_name MoveState
extends HeroState

# Move to target
var target: Vector2 = Vector2.ZERO
# or
# Move in direction
var direction: Vector2 = Vector2.ZERO


func enter():
	hero.target_line.show()

func exit():
	hero.target_line.hide()

func process_input(event: InputEvent) -> HeroState:
	return null


func process_physics(delta: float) -> Array:
	if hero.interrupted:
		hero.interrupted = false
		return []
	
	if not "Stunned" in sm.state_statuses and not "Rooted" in sm.state_statuses:
		hero.move(target, delta)
	
	var airborne = not hero.is_on_floor()
	if airborne:
		return [func(): sm.change_state(sm.fall_state)]
	if pending_state:
		return [func(): sm.change_state(pending_state)]
	else:
		if (Vector2(hero.position.x, hero.position.z) - target).length() == 0:
			return [func(): sm.change_state(sm.idle_state)]
		return []

func process_frame(delta: float) -> HeroState:
	var t = Vector3(target.x, hero.position.y, target.y)
	t = to_local(t)
	hero.draw_line(t)
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return
	
	if input.key in SpellList.cast_keys:
		return sm.cast_state
	
	if input.key == MOUSE_BUTTON_RIGHT:
		target = input.target
	

func decode(dict: Dictionary):
	target = dict['target']
	return self

func serialize():
	return {
		'state_name': 'Move',
		'target': self.target
	}

