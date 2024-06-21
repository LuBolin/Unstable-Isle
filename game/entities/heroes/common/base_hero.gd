@tool
class_name Hero
extends CharacterBody3D

signal hero_died(id)

const PlayerState = Serializables.PlayerState
const PlayerInput = Serializables.PlayerInput

var hero_assets: HeroAssetHolder
var spell_list: SpellList

@onready var target_line: MeshInstance3D = $Base/TargetLine

const hero_node = preload("res://game/entities/heroes/common/base_hero.tscn")

var controller_id: int # netwprl unique id
var health: int = 10 :
	set(new_health):
		health = new_health
		var l = get_node_or_null("HealthLabel")
		if l:
			l.set_text("Health: %s" % [str(health)])
@onready var state_manager: StateManager = $StateManager
@onready var unit_manager: UnitManager = $UnitManager
@onready var status_manager: StatusManager = $StatusManager
var movement

var interrupted = false
var statuses: Dictionary = {}

static func create(c_id: int, hero_name: String, 
	initial_pos: Vector3, is_self: bool):
	var hero = hero_node.instantiate()
	var assets: HeroAssetHolder = get_hero_asset_holder(hero_name)
	hero.init(c_id, hero_name, initial_pos, is_self, assets)
	return hero

func init(c_id: int, name: String, 
	initial_pos: Vector3, is_self: bool, hah: HeroAssetHolder):
	controller_id = c_id

	state_manager = $StateManager
	state_manager.init(self)
	
	unit_manager = $UnitManager
	#unit_manager.init(self)
	
	status_manager = $StatusManager
	status_manager.init(self)
	
	movement = $Movement
	movement.init(self)

	hero_assets = hah
	spell_list = hero_assets.spell_list
	
	get_node("Paper").set_texture(hero_assets.portrait_icon)

	self.name = name
	if is_self:
		var ring = get_node("Base/Ring")
		# Inspector -> Resource -> Local to Scene
		ring.get_mesh().surface_get_material(0).albedo_color = Color.GREEN
	position = initial_pos

func simulate(state: PlayerState, input: PlayerInput):
	position = state.position
	health = state.health
	var hs = state.hero_state # HeroState.decode(state.hero_state)
	statuses = state.statuses # HeroStatus.decode(state.statuses)
	movement.reset()
	for spell in state.spell_cooldowns.keys():
		# "spell_name": current_cooldown
		var current_cd = state.spell_cooldowns[spell]
		spell_list.get(spell).current_cooldown = current_cd
	
	var interactions = []
	unit_manager.derivatives_count = state.derivatives["d_count"]
	unit_manager.drop_freed(state.derivatives["unit_states"])
	status_manager.drop_freed(statuses["unit_statuses"])
	var sm_interactions = state_manager.simulate(hs, input)
	interactions += (sm_interactions)
	
	var unit_interactions = unit_manager.simulate(state.derivatives, input)
	interactions += unit_interactions
	
	var status_interactions = status_manager.simulate(statuses, input)
	interactions += status_interactions
	
	return interactions

func get_state():
	return PlayerState.new(
		position, health, 
		state_manager.current_state, 
		status_manager.get_state(), 
		unit_manager.get_state(),
		spell_list.get_current_cooldowns(),
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

#status
func apply_status(status : HeroStatus):
	status_manager.apply_status(status)

# Movement
func move(target: Vector2, delta: float):
	movement.move(target, delta)

func modify_speed(percentage):
	movement.modify_speed(percentage)

const path_to_hero_asset = "res://game/entities/heroes/specifics/%s/%s_assets.tres"
static func get_hero_asset_holder(hero_name: String):
	var path = path_to_hero_asset % [hero_name, hero_name]
	var data: HeroAssetHolder = load(path)
	return data.duplicate(true)