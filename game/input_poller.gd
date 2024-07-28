class_name InputPoller
extends Node3D

var input_queue = []

const CAP = 300

var CAM_CONTROL_INPUTS = [
	KEY_W, KEY_A, KEY_S, KEY_D,
	MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN,
]

const VALID_INPUTS = [
	MOUSE_BUTTON_LEFT,
	KEY_Q, KEY_W, KEY_E, KEY_R,
	MOUSE_BUTTON_RIGHT # movement
]

var gameroom_gui_controller: GameroomGuiController

func _ready():
	gameroom_gui_controller = get_parent().get_node('GUI')

func _input(event):
	if len(input_queue) > CAP:
		return
	var chat: GameroomChat = gameroom_gui_controller.chat
	# inputs are to chat, not as game inputs
	if chat.is_chatting:
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
		# InputRaycastTargetBody: Layer = 4
		rayQuery.set_collision_mask(0b1000)
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
	return Serializables.PlayerInput.decode(input)
