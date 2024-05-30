extends Node3D

var input_queue = []

const CAP = 300

var CAM_CONTROL_INPUTS = [
	KEY_W, KEY_A, KEY_S, KEY_D,
	MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN,
]

const VALID_INPUTS = [
	KEY_Q, # KEY_W, KEY_E, KEY_R,
	MOUSE_BUTTON_RIGHT # movement
]

func _input(event):
	if len(input_queue) > CAP:
		return
	if event is InputEvent and event.is_pressed():
		var key = KEY_NONE
		if event is InputEventMouseButton:
			key = event.button_index
		elif event is InputEventKey:
			key = event.keycode
		if key not in VALID_INPUTS:
			return
		
		var mousePos = get_viewport().get_mouse_position()
		var camera_3d = get_viewport().get_camera_3d()
		var from = camera_3d.project_ray_origin(mousePos)
		var to = from + camera_3d.project_ray_normal(mousePos) * 1000
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		rayQuery.from = from
		rayQuery.to = to
		
		var result: Dictionary = space.intersect_ray(rayQuery)
		if not result.is_empty():
			var target = result['position']
			target = Vector2(target.x, target.z)
			input_queue.append({"target": target, "key": key})


func poll_game_input(frame) -> Serializables.PlayerInput:
	if input_queue.is_empty():
		return null
	var input = input_queue.pop_front()
	input['frame'] = frame
	# print("Polled: %s " % [input])
	return Serializables.PlayerInput.decode(input)
