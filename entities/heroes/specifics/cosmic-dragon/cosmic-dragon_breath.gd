class_name CosmicDragonBreath
extends ShapeCast3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_breath.tscn")

const SPEED: float = 100.0

var id: int
var type = "CosmicDragonBreath"
var direction: Vector2
var lifespan: float = 5
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	var dirn: Vector2 = \
		target - Vector2(
			hero.global_position.x,
			hero.global_position.z)
	
	var manager: UnitManager = hero.unit_manager
	var b_id = manager.add(bullet)
	bullet.init(b_id, dirn, hero)
	return bullet

func init(b_id: int, dirn: Vector2, h: Hero):
	id = b_id
	direction = dirn.normalized()
	hero = h
	global_position = hero.global_position

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	lifespan = unit_states['lifespan']
	direction = unit_states['direction']
	var delta = get_physics_process_delta_time()
	global_position = hero.global_position + Vector3(direction.x, 0.5, direction.y) * 50
	
	lifespan -= delta
	look_at(global_position + Vector3(direction.x, 0, direction.y))
	#apply every 0.2 seconds
	if not floor(lifespan * 5) == floor((lifespan - delta) * 5):
		var count = get_collision_count()
		for i in range(count):
			var target = get_collider(i)
			if target == hero:
				continue
			if target is Hero:
				var slow = CosmicDragonBreathSlow.new()
				slow.create(hero, slow.total_duration, direction)
				target.apply_status(slow)
				interactions.append(func(): target.movement.push(direction, 300))
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
		}
