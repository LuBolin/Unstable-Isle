@tool
class_name Hero
extends CharacterBody3D

const PlayerState = Serializables.PlayerState
const PlayerInput = Serializables.PlayerInput

# 6 columns, 5 rows
@export var sprite_sheet: Texture2D
const sheet_col_count = 4; const sprite_dim = 32
@export_range (0, 29) var character: int:
	set(value):
		character = value
		var row = value / sheet_col_count
		var col = value % sheet_col_count
		var rect = Rect2(
			col*sprite_dim, row*sprite_dim, sprite_dim, sprite_dim)
		# don't use get_node here, errors are annoying
		# this is an editor helper only anyways
		var p = get_node_or_null("Paper")
		if p:
			var at = AtlasTexture.new()
			at.atlas = sprite_sheet
			at.region = rect
			p.set_sprite(at)

@export var spell_list: SpellList

@onready var target_line: MeshInstance3D = $Base/TargetLine


var controller_id: int # netwprl unique id
var health: int = 10 :
	set(new_health):
		health = new_health
		var l = get_node_or_null("HealthLabel")
		if l:
			l.set_text("Health: %s" % [str(health)])
@onready var state_manager: StateManager = $StateManager
@onready var unit_manager: UnitManager = $UnitManager

var interrupted = false
var statuses: Dictionary = {}

var names = {
	"Dwarf": 0,
	"Elf Rogue": 1,
	"Ranger": 2,
	"Burglar": 3,
	"Sword Knight": 4,
	"Sword Civilian": 5,
}

func _ready():
	character = character

func create(c_id: int, name: String, initial_pos: Vector3):
	controller_id = c_id

	state_manager = $StateManager
	state_manager.init(self)
	
	unit_manager = $UnitManager
	#unit_manager.init(self)

	self.name = name
	if c_id == Network.multiplayer.get_unique_id():
		var ring = get_node("Base/Ring")
		# Inspector -> Resource -> Local to Scene
		ring.get_mesh().surface_get_material(0).albedo_color = Color.GREEN
	if name in names:
		var i = names[name]
		character = i
	else:
		character = 29
	position = initial_pos
	print("%s created at %s" % [c_id, initial_pos])

func simulate(state: PlayerState, input: PlayerInput):
	position = state.position
	health = state.health
	var hs = state.hero_state # HeroState.decode(state.hero_state)
	statuses = state.statuses # HeroStatus.decode(state.statuses)
	
	var interactions = []
	unit_manager.derivatives_count = state.derivatives["d_count"]
	unit_manager.drop_freed(state.derivatives["unit_states"])
	var sm_interactions = state_manager.simulate(hs, input)
	#interactions.append(sm_interactions)
	
	var unit_interactions = unit_manager.simulate(state.derivatives, input)
	interactions += unit_interactions
	
	return interactions

func get_state():
	return PlayerState.new(
		position, health, 
		state_manager.current_state, 
		statuses, 
		unit_manager.get_state()
	)

# Non-logic
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
