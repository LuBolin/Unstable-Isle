class_name DwarfWall
extends StaticBody3D

@onready var initial_stun_shape_cast: ShapeCast3D = $InitialStunShapeCast

const bullet_scene = preload("res://entities/heroes/specifics/dwarf/dwarf_wall.tscn")

var id: int
var type = "DwarfWall"
var direction: Vector2
var lifespan: float = 10
var hero : Hero
var health = 5
var hit_scanned: bool = false

@export var speed_curve: Curve

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	var dirn: Vector2 = \
		target - Vector2(
			hero.global_position.x,
			hero.global_position.z)
	dirn = dirn.normalized()
	
	var manager: UnitManager = hero.unit_manager
	var b_id = manager.add(bullet)
	bullet.init(b_id, dirn, hero)
	return bullet

var hits = []

func init(b_id: int, dirn: Vector2, h: Hero):
	id = b_id
	direction = dirn
	hero = h
	
	var dirn_v3: Vector3 = Vector3(direction.x, 0, direction.y)
	var look_target = global_position + dirn_v3.normalized()
	look_at(look_target)

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	direction = unit_states['direction']
	var dirn: Vector3 = Vector3(direction.x, 0, direction.y)
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()

	var look_target = global_position + dirn.normalized()
	look_at(look_target)
	
	if not hit_scanned:
		hit_scanned = true
		var hits = []
		initial_stun_shape_cast.target_position = Vector3.ZERO
		initial_stun_shape_cast.force_shapecast_update()
		for target in initial_stun_shape_cast.collision_result:
			var collider = target['collider']
			if collider in hits or collider == hero:
				continue
			hits.append(collider)
			if collider.get("health"):
				interactions.append(func(): collider.health -= 1)
			if collider is Hero:
				var stun = DwarfWallStun.new()
				stun.create(hero, stun.total_duration)
				#interactions.append(func(): target.apply_status(slow))
				collider.apply_status(stun)

	lifespan -= delta
	if lifespan < 0:
		var node = self
		var parent = get_parent()
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan,
		'hit_scanned' : hit_scanned,
		'health' : health,
		}
