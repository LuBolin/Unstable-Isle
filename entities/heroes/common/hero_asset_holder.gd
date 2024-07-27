class_name HeroAssetHolder
extends Resource

@export var hero_name: String
@export var picker_texture: Texture2D:
	set(texture):
		picker_texture = texture
		portrait_icon.set_atlas(texture)
		portrait_icon.set_region(portrait_region)
		atk_icon.set_atlas(texture)
		atk_icon.set_region(atk_region)
		fst_icon.set_atlas(texture)
		fst_icon.set_region(fst_region)
		scd_icon.set_atlas(texture)
		scd_icon.set_region(scd_region)
		ult_icon.set_atlas(texture)
		ult_icon.set_region(ult_region)
@export_multiline var atk_description: String = "Basic Attack"
@export_multiline var fst_description: String = "First Spell"
@export_multiline var scd_description: String = "Second Spell"
@export_multiline var ult_description: String = "Ultimate"
@export var spell_list: SpellList

var texture_width: int = 64
var texture_size: Vector2 = Vector2(texture_width, texture_width)

var portrait_icon: AtlasTexture = AtlasTexture.new()
var portrait_origin: Vector2 = Vector2(0, 0)
var portrait_region: Rect2 = Rect2(portrait_origin, texture_size)

var atk_icon: AtlasTexture = AtlasTexture.new()
var atk_origin: Vector2 = Vector2(0, texture_width)
var atk_region: Rect2 = Rect2(atk_origin, texture_size)

var fst_icon: AtlasTexture = AtlasTexture.new()
var fst_origin: Vector2 = Vector2(texture_width, texture_width)
var fst_region: Rect2 = Rect2(fst_origin, texture_size)

var scd_icon: AtlasTexture = AtlasTexture.new()
var scd_origin: Vector2 = Vector2(0, 2*texture_width)
var scd_region: Rect2 = Rect2(scd_origin, texture_size)

var ult_icon: AtlasTexture = AtlasTexture.new()
var ult_origin: Vector2 = Vector2(texture_width, 2*texture_width)
var ult_region: Rect2 = Rect2(ult_origin, texture_size)
