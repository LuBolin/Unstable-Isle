class_name BirdsEye3DCamera
extends Camera3D

const CAM_ANGLE: int = -65
# const CAM_ANGLE: int = -90 # only for testing projectiles

const CAM_MAX_HEIGHT: int = 400
const CAM_MIN_HEIGHT: int = 150
const zoom_speed = 5.0
const scroll_scale = 3.0
const cam_default_focus = Vector2(0, 100)
const edge_pan_speed = 500.0

var target_hero = null

func _init():
	reset()

var panning = false
var pan_origin = Vector2.ZERO

var edge_pan = false

func reset():
	rotation = Vector3(deg_to_rad(CAM_ANGLE), 0, 0)
	position.y = CAM_MAX_HEIGHT * 0.75
	focus_at(cam_default_focus)

func _input(event):
	if event is InputEventMouse:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				panning = event.is_pressed()
				pan_origin = get_focus_point(true)
	elif event is InputEventKey:
		if not target_hero:
			if event.is_pressed and event.keycode == KEY_SPACE:
				focus_at(cam_default_focus)
		var game_room: GameRoom = target_hero.game_room
		var chat: GameroomChat = game_room.gui.chat
		if chat.is_chatting:
			return 
		if event.is_pressed() and event.keycode == KEY_SPACE:
			if target_hero:
				var temp = target_hero.global_position
				focus_at(Vector2(temp.x, temp.z))
			else:
				focus_at(cam_default_focus)
		elif event.is_pressed and event.keycode == KEY_CAPSLOCK:
			edge_pan = not edge_pan

func _process(delta: float) -> void:
	if panning:
		var diff = get_focus_point(true) - pan_origin
		if diff:
			focus_at(get_focus_point() - diff)
			pan_origin = get_focus_point(true)
	
	# Zoom
	var zoom_dirn: Vector3 = Vector3.ZERO
	if Input.is_action_just_pressed("scroll_up"):
		zoom_dirn -= transform.basis.z * scroll_scale
	elif Input.is_action_just_pressed("scroll_down"):
		zoom_dirn += transform.basis.z * scroll_scale
	zoom_dirn *= zoom_speed
	var target_y = position.y + zoom_dirn.y
	if target_y > CAM_MAX_HEIGHT:
		var allowed = CAM_MAX_HEIGHT - position.y
		zoom_dirn *= allowed / zoom_dirn.y
	elif target_y < CAM_MIN_HEIGHT:
		var allowed = position.y - CAM_MIN_HEIGHT
		zoom_dirn *= allowed / -zoom_dirn.y
	global_translate(zoom_dirn)
	
	if edge_pan:
		# Edge panning
		var screen_size = get_viewport().size
		var mouse_position = get_viewport().get_mouse_position()
		var edge_pan_dirn = Vector3.ZERO

		if mouse_position.x <= 10: # Left edge
			edge_pan_dirn.x -= edge_pan_speed * delta
		elif mouse_position.x >= screen_size.x - 10: # Right edge
			edge_pan_dirn.x += edge_pan_speed * delta

		if mouse_position.y <= 10: # Top edge
			edge_pan_dirn.z -= edge_pan_speed * delta
		elif mouse_position.y >= screen_size.y - 10: # Bottom edge
			edge_pan_dirn.z += edge_pan_speed * delta

		global_translate(edge_pan_dirn)

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


func get_focus_point(use_cursor: bool = false) -> Vector2:
	var focus_point = Vector2()
	var current_position = position

	if use_cursor:
		var cursor_position = get_viewport().get_mouse_position()
		var from = project_ray_origin(cursor_position)
		var to = from + project_ray_normal(cursor_position) * 1000
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		# InputRaycastTargetBody: Layer = 4
		rayQuery.set_collision_mask(0b1000)
		rayQuery.from = from
		rayQuery.to = to
		
		var result: Dictionary = space.intersect_ray(rayQuery)
		current_position = result['position']

	focus_point.x = current_position.x

	# Calculate the z_over_y using the same angle as in focus_at
	var z_over_y = atan(deg_to_rad(90 + CAM_ANGLE))

	# Given the current position, calculate the focus point in the x-z plane
	var delta_z = current_position.y * z_over_y
	focus_point.y = current_position.z - delta_z

	return focus_point
