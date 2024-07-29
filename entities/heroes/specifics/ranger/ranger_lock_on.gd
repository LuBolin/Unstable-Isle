class_name RangerLockOn
extends ShapeCast3D

const bullet_scene = preload("res://entities/heroes/specifics/ranger/ranger_lock_on.tscn")

const SPEED: float = 200.0

var id: int
var type = "RangerLockOn"
var direction: Vector2
var lifespan: float = 1
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	
	var manager: UnitManager = hero.unit_manager
	var b_id = manager.add(bullet)
	bullet.init(b_id, target, hero)
	return bullet

func init(b_id: int, dirn: Vector2, h: Hero):
	id = b_id
	global_position = Vector3(dirn.x, 0, dirn.y)
	hero = h

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()
	
	#force_shapecast_update()
	#var hits = []
	#for res in collision_result:
		#var collider = res['collider']
		#if collider in hits:
			#continue
		#hits.append(collider)
		#if collider is Hero:
			#var target : Hero = collider
	var collision = get_collider(0)
	if collision:
		if collision is Hero:
			var target : Hero = collision
			var locked_on = RangerLockedOn.new()
			locked_on.create(hero, locked_on.total_duration)
			locked_on.init(target.controller_id)
			hero.apply_status(locked_on)
			
			var locked_on_target = RangerLockedOnTarget.new()
			locked_on_target.create(hero, locked_on_target.total_duration)
			target.apply_status(locked_on_target)
			lifespan = -1	#remove
	
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
		'lifespan' : lifespan
		}
