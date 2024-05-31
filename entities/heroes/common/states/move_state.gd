class_name MoveState
extends HeroState

@export var idle_state: HeroState

var speed = 50
var target: Vector2 = Vector2.ZERO

func enter():
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func process_physics(delta: float) -> HeroState:
	if hero.interrupted:
		hero.interrupted = false
		return null
	
	var dirn: Vector3 = Vector3(
		target.x - hero.position.x, 0,
		target.y - hero.position.z)
	if dirn.length() > 0:
		var vel = dirn.normalized() * speed
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

	if pending_state:
		return pending_state
	else:
		if (Vector2(hero.position.x, hero.position.z) - target).length() == 0:
			return idle_state
		return null

func process_frame(delta: float) -> HeroState:
	var t = Vector3(target.x, hero.position.y, target.y)
	t = to_local(t)
	hero.draw_line(t)
	return null

func simulate_input(input: PlayerInput):
	if not input:
		return
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

