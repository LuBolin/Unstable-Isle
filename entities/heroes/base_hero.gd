@tool
class_name Hero
extends CharacterBody3D

@onready var paper = $Paper
@onready var ring: MeshInstance3D = $Base/Ring
@onready var target_line: MeshInstance3D = $TargetLine

# 6 columns, 5 rows
@export var sprite_sheet: Texture2D
const sheet_col_count = 6; const sprite_dim = 91
@export_range (0, 29) var character: int:
	set(value):
		character = value
		var row = value / 6
		var col = value % 6
		var rect = Rect2(
			col*sprite_dim, row*sprite_dim, sprite_dim, sprite_dim)
		# don't use get_node here
		# errors are annoying
		# this is an editor helper only anyways
		var p = get_node_or_null("Paper")
		if p:
			var topLeft = Vector2(100, 150)
			var bottomRight = Vector2(300, 325)
			var size = bottomRight - topLeft

			var at = AtlasTexture.new()
			at.atlas = sprite_sheet
			at.region = rect
			p.set_sprite(at)

var speed = 200
var controller_id = 1

var target: Vector3 = Vector3.ZERO


func _ready():
	character = character

func create(c_id: int, initial_pos: Vector3):
	controller_id = c_id
	self.name = str(c_id)
	if c_id == Network.multiplayer.get_unique_id():
		ring = get_node("Base/Ring")
		# Inspector -> Resource -> Local to Scene
		ring.get_mesh().surface_get_material(0).albedo_color = Color.GREEN
	position = initial_pos
	target = position
	# position = Vector2(randf_range(0,500), randf_range(0,500))
	print("%s created at %s" % [c_id, initial_pos])
	return State.new(position, target).serialize()

func simulate(state, input: Dictionary):
	position = state["position"]
	if not input.is_empty():
		target = input["target"]
	else:
		target = state['target']
	
	target.y = self.position.y
	var t = to_local(target)
	#trail.set_point_position(1, t)
	draw_line(t)
	
	var dirn = target - position
	if dirn.length() > 0:
		var vel = dirn.normalized() * speed
		# set velocity before move_and_slide
		velocity = vel
		move_and_slide()
		
		# overshot)
		var angle_diff = abs((target - position).signed_angle_to(vel, Vector3.UP))
		# closer to PI than 0 or 2PI
		var overshot = angle_diff > PI/2.0 and angle_diff < 3.0/2.0 * PI
		if overshot:
			position = target
	return State.new(position, target).serialize()

func draw_line(target: Vector3):
	var length = target.distance_to(Vector3.ZERO)

	var mid_point = target / 2.0
	target_line.position = mid_point

	target_line.get_mesh().height = length

	# Calculate the rotation needed to align the cylinder with the target
	var direction = target.normalized()
	var angle = atan2(direction.x, direction.z)
	# Rotate 90 degrees around the x-axis and then align with target
	target_line.rotation_degrees = Vector3(90, 0, -angle * 180 / PI)


class State:
	var position
	var target
	func _init(p, t):
		position = p
		target = t
	func serialize():
		return {
			"position" : position,
			"target" : target,
		}
