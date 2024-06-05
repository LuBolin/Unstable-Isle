class_name MoveState
extends HeroState

const DEFAULT_SPEED: float = 50
var modified_speed: float
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

func clean_up():
	modified_speed = DEFAULT_SPEED

func process_physics(delta: float) -> HeroState:
	if hero.interrupted:
		hero.interrupted = false
		return null
	
	var dirn: Vector3 = Vector3(
		target.x - hero.position.x, 0,
		target.y - hero.position.z)
	if position != Vector3(target.x, hero.position.y, target.y):
		$MovingTowardsVoidCheck.look_at(Vector3(target.x, hero.position.y, target.y))
	
	var moving_towards_void = false
	for rc in $MovingTowardsVoidCheck.get_children():
		if not rc is RayCast3D:
			continue
		if not rc.is_colliding():
			moving_towards_void = true
			break
	if moving_towards_void:
		modified_speed *= 0.2

	if dirn.length() > 0:
		var vel = dirn.normalized() * modified_speed
		# set velocity before move_and_slide
		hero.velocity = vel
		hero.move_and_slide()
		
		# overshot
		var new_delta : Vector3 = Vector3(
			target.x - hero.position.x, 0,
			target.y - hero.position.z)
		var angle_diff = abs(new_delta\
			.signed_angle_to(vel, Vector3.UP))
		# closer to PI than 0 or 2PI
		var overshot = angle_diff > PI/2.0 and angle_diff < 3.0/2.0 * PI
		if overshot:
			hero.position.x = target.x
			hero.position.z = target.y

	var airborne = not hero.is_on_floor()
	if airborne:
		return sm.fall_state
	if pending_state:
		return pending_state
	else:
		if (Vector2(hero.position.x, hero.position.z) - target).length() == 0:
			return sm.idle_state
		return null

func process_frame(delta: float) -> HeroState:
	var t = Vector3(target.x, hero.position.y, target.y)
	t = to_local(t)
	hero.draw_line(t)
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return
	if input.key == 81:
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

