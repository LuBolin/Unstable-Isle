@tool
class_name Hero
extends CharacterBody3D

const PlayerState = Serializables.PlayerState
const PlayerInput = Serializables.PlayerInput

var hero_assets: HeroAssetHolder
var spell_list: SpellList

@onready var target_line: MeshInstance3D = $Base/TargetLine

const hero_node = preload("res://entities/heroes/common/base_hero.tscn")

var controller_id: int # netwprl unique id
var health: int = 10 :
	set(new_health):
		health = new_health
		var l = get_node_or_null("HealthLabel")
		if l:
			l.set_text("Health: %s" % [str(health)])
		if health <= 0:
			print(multiplayer.get_unique_id())
			state_manager.change_state(state_manager.death_state)
var game_room: GameRoom
@onready var state_manager: StateManager = $StateManager
@onready var unit_manager: UnitManager = $UnitManager
@onready var status_manager: StatusManager = $StatusManager
var movement

var interrupted = false
var statuses: Dictionary = {}
@onready var status_label = $StatusLabel

static func create(c_id: int, hero_name: String, 
	initial_pos: Vector3, is_self: bool, gr: GameRoom):
	var hero = hero_node.instantiate()
	var assets: HeroAssetHolder = get_hero_asset_holder(hero_name)
	hero.init(c_id, hero_name, initial_pos, is_self, assets, gr)
	return hero

func init(c_id: int, name: String, 
	initial_pos: Vector3, is_self: bool, 
	hah: HeroAssetHolder, gr: GameRoom):
	controller_id = c_id
	
	game_room = gr
	
	state_manager = $StateManager
	state_manager.init(self)
	
	unit_manager = $UnitManager
	unit_manager.init(self)
	
	status_manager = $StatusManager
	status_manager.init(self)
	
	movement = $Movement
	movement.init(self)
	
	status_label = $StatusLabel

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
	
	var is_dead = hs.serialize()['state_name'] == 'Death'
	if is_dead:
		game_room.round.is_dead_dict[controller_id] = true
	else:
		game_room.round.is_dead_dict.erase(controller_id)
	
	var interactions = []
	unit_manager.derivatives_count = state.derivatives["d_count"]
	state_manager.clean_up()
	unit_manager.drop_freed(state.derivatives["unit_states"])
	status_manager.drop_freed(statuses["unit_statuses"])
	
	var status_interactions = status_manager.simulate(statuses, input)
	interactions += status_interactions
	
	var state_interactions = state_manager.simulate(hs, input)
	interactions += (state_interactions)
	
	var unit_interactions = unit_manager.simulate(state.derivatives, input)
	interactions += unit_interactions
	
	
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

const path_to_hero_asset = "res://entities/heroes/specifics/%s/%s_assets.tres"
static func get_hero_asset_holder(hero_name: String):
	hero_name = hero_name.to_lower()
	var path = path_to_hero_asset % [hero_name, hero_name]
	var data: HeroAssetHolder = load(path)
	return data.duplicate(true)
