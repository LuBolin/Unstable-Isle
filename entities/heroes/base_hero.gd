@tool
class_name Hero
extends CharacterBody3D

@onready var paper = $Paper

@export var sprite_sheet: Texture2D

# 6 columns, 5 rows
const sheet_col_count = 6
const sprite_dim = 91
@export_range (0, 29) var character: int:
	set(value):
		character = value
		var row = value / 6
		var col = value % 6
		var rect = Rect2(
			col*sprite_dim, row*sprite_dim, sprite_dim, sprite_dim)
		if $Paper:
			var topLeft = Vector2(100, 150)
			var bottomRight = Vector2(300, 325)
			var size = bottomRight - topLeft

			var at = AtlasTexture.new()
			at.atlas = sprite_sheet
			at.region = rect
			$Paper.set_sprite(at)

func _ready():
	# confirm initialization
	character = character
	pass

func _process(delta):
	pass
