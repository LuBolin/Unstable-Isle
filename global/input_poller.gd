extends Node3D

var input_queue = []

const CAP = 300

func _input(event):
	if len(input_queue) > CAP:
		return
	if event is InputEvent and event.is_pressed():
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
			var key = KEY_NONE
			if event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT:
				key = event.button_index
			elif event is InputEventKey:
				key = event.keycode
			input_queue.append({"target": target, "key": key})


func poll_game_input(frame) -> Dictionary:
	if input_queue.is_empty():
		return {}
	var input = input_queue.pop_front()
	input['frame'] = frame
	print("Polled: %s " % [input])
	return input
