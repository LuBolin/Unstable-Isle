class_name BcAttack
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/bc/bc_attack.tscn")

const SPEED: float = 100.0

var id: int
var direction: Vector2
var lifespan: float = 3

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	bullet.add_collision_exception_with(hero)
	var direction: Vector2 = \
		target - Vector2(
			hero.global_position.x,
			hero.global_position.z)
	
	var manager: UnitManager = hero.unit_manager
	bullet.init(
		manager.derivatives_count, direction)
	manager.add_child(bullet)
	manager.derivatives_count += 1

func init(b_id: int, dirn: Vector2):
	id = b_id
	direction = dirn

func simulate(unit_states):
	global_position = unit_states['position']
	direction = unit_states['direction']
	var dirn: Vector3 = Vector3(direction.x, 0, direction.y)
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()
	if lifespan < delta:
		velocity = dirn.normalized() * SPEED * (lifespan/delta)
	else:
		velocity = dirn.normalized() * SPEED
	
	var look_target = position + velocity
	if not transform.origin.is_equal_approx(look_target):
		look_at(look_target)
	
	move_and_slide()
	lifespan -= delta
	if lifespan < 0:
		return [queue_free]
	return []


func get_state():
	return {'id' : id,\
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan
		}
