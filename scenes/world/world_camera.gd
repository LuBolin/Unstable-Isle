extends Camera3D

const CAM_ANGLE: int = -65
const CAM_MAX_HEIGHT: int = 400
const CAM_MIN_HEIGHT: int = 150
const pan_speed = 5.0
const scroll_scale = 3.0

func _init():
	rotation = Vector3(deg_to_rad(CAM_ANGLE), 0, 0)
	position.y = CAM_MAX_HEIGHT * 0.75
	# focus_at(Vector2.ZERO)
	focus_at(Vector2(0, 50))

var panning = false
var pan_origin = Vector2.ZERO

func _input(event):
	if event is InputEventMouse:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				panning = event.is_pressed()
				pan_origin = event.get_position()

func _process(delta: float) -> void:
	if panning:
		var pan_dirn_v2 = get_viewport().get_mouse_position() - pan_origin
		pan_dirn_v2 *= -1
		pan_dirn_v2 /= 100.0 # less make tanh less abrupt
		# tanh scaled to (-1, 1)
		var pan_dirn_v3: Vector3 = Vector3(
			tanh(pan_dirn_v2.x), 0, tanh(pan_dirn_v2.y)
		)
		pan_dirn_v3 *= pan_speed
		global_translate(pan_dirn_v3)
			
	var zoom_dirn: Vector3 = Vector3.ZERO
	if Input.is_action_just_pressed("scroll_up"):
		zoom_dirn -= transform.basis.z * scroll_scale
	elif Input.is_action_just_pressed("scroll_down"):
		zoom_dirn += transform.basis.z * scroll_scale
	zoom_dirn *= pan_speed
	var target_y = position.y + zoom_dirn.y
	if target_y > CAM_MAX_HEIGHT:
		var allowed = CAM_MAX_HEIGHT - position.y
		zoom_dirn *= allowed / zoom_dirn.y
	elif target_y < CAM_MIN_HEIGHT:
		var allowed = position.y - CAM_MIN_HEIGHT
		zoom_dirn *= allowed / -zoom_dirn.y
	global_translate(zoom_dirn)
	
	#var adjust_dirn: Vector3 = Vector3.ZERO
	#if Input.is_key_pressed(KEY_W):
		#adjust_dirn.z -= 1
	#if Input.is_key_pressed(KEY_S):
		#adjust_dirn.z += 1
	#if Input.is_key_pressed(KEY_A):
		#adjust_dirn -= transform.basis.x
	#if Input.is_key_pressed(KEY_D):
		#adjust_dirn += transform.basis.x
	#global_translate(adjust_dirn * pan_speed)

func focus_at(pos: Vector2) -> void:
	# given angle and height, calculate
	var target = Vector3.ZERO
	target.x = pos.x
	target.y = position.y
	# complement of the angle
	var z_over_y = atan(deg_to_rad(90 + CAM_ANGLE))
	var delta_z = target.y * z_over_y
	# pos is in x-z plane, thus pos.y is z
	# + delta because +ve. z-axis is downwards
	# and we point diagonally towards the -ve z direction
	target.z = pos.y + delta_z
	position = target
