extends Camera3D

const CAM_ANGLE: int = -65
const CAM_MAX_HEIGHT: int = 400
const CAM_MIN_HEIGHT: int = 200
const move_speed = 10.0
const scroll_scale = 2.0

func _init():
	rotation = Vector3(deg_to_rad(CAM_ANGLE), 0, 0)
	position.y = CAM_MAX_HEIGHT * 0.75
	# focus_at(Vector2.ZERO)
	focus_at(Vector2(0, 50))


func _process(delta: float) -> void:
	var zoom_dirn: Vector3 = Vector3.ZERO
	if Input.is_action_just_pressed("scroll_up"):
		zoom_dirn -= transform.basis.z * scroll_scale
	elif Input.is_action_just_pressed("scroll_down"):
		zoom_dirn += transform.basis.z * scroll_scale
	zoom_dirn *= move_speed
	var target_y = position.y + zoom_dirn.y
	if target_y > CAM_MAX_HEIGHT:
		var allowed = CAM_MAX_HEIGHT - position.y
		zoom_dirn *= allowed / zoom_dirn.y
	elif target_y < CAM_MIN_HEIGHT:
		var allowed = position.y - CAM_MIN_HEIGHT
		zoom_dirn *= allowed / -zoom_dirn.y
	global_translate(zoom_dirn)
	
	var adjust_dirn: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		adjust_dirn.z -= 1
	if Input.is_key_pressed(KEY_S):
		adjust_dirn.z += 1
	if Input.is_key_pressed(KEY_A):
		adjust_dirn -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		adjust_dirn += transform.basis.x
	global_translate(adjust_dirn * move_speed)

func focus_at(pos: Vector2) -> void:
	# given angle and height, calculate
	var target = Vector3.ZERO
	target.x = pos.x
	target.y = position.y
	# complement of the angle
	var z_over_y = atan(deg_to_rad(90 + CAM_ANGLE))
	var delta_z = target.y * z_over_y
	print("Delta is ", delta_z)
	print("Target is ", pos.y)
	# pos is in x-z plane, thus pos.y is z
	# + delta because +ve. z-axis is downwards
	# and we point diagonally towards the -ve z direction
	target.z = pos.y + delta_z
	position = target
