extends Node

const ISLAND_RADIUS: int = 400
const SPAWN_RADIUS_PERCENT: float = 0.75

const HERO_RADIUS: int = 12

const CAM_ANGLE: int = -65
const SKY_BOX_ANGLE: int = -205
# -65 is experimented to look at things on the X-Z plane
# CAM_FOV = 75: ~100 degrees
# camera's bottom edge is at -65 - 50 = -115
# camera's 0 degree default is on the X-Z plane
# skybox's 0 degree default has sky up the Y axis
# thus offset by another -90
# thus skybox is at -115 - 90 = -205 degrees

const PICK_PHASE_DURATION = 10
const DRAW_WAIT_DURATION = 1
const DISPLAY_FINAL_RESULT_DURATION = 7

const ROOM_MAX_PLAYERS = 4

const GRAVITY: int = 200
const KILL_HEIGHT: int = -800 # 0.5 * A * t^2, 2 seconds, A = 200, D = 800

const SCORE_TO_WIN: int = 3

const POLL_PER_FRAME: float = 5

# saves last X frames
# buffer 0.1 seconds, 60fps -> 6 physics frames
# 5 poll per frame -> 30 buffer frames
const BUFFER_SIZE = 30
# tolerate inputs up to 1/2 of buffer ahead of servcer
const LEAD_TOLERANCE = BUFFER_SIZE * 0.5

# var, because we may want to allow custom controls
var input_prompt_txtr_dict = {
	'atk': preload("res://resources/input_prompts/mouse_left_outline.png"),
	'fst': preload('res://resources/input_prompts/keyboard_q_outline.png'),
	'scd': preload('res://resources/input_prompts/keyboard_w_outline.png'),
	'ult': preload('res://resources/input_prompts/keyboard_r_outline.png')
}
# Layers
# 1: Physics
# 4: Input World Boundary Plane
