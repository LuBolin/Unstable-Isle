extends Node3D

var hero : Hero
const DEFAULT_SPEED: float = 50
var modified_speed: float
# Move to target
var target: Vector2 = Vector2.ZERO
# or
# Move in direction
var direction: Vector2 = Vector2.ZERO

func init(h : Hero) -> void:
	hero = h
	modified_speed = DEFAULT_SPEED

func reset():
	modified_speed = DEFAULT_SPEED

func modify_speed(percentage):
	modified_speed *= percentage

func move(target: Vector2, delta: float) -> void:
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
	if "Flying" in hero.state_manager.state_statuses:
		moving_towards_void = false
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
	
