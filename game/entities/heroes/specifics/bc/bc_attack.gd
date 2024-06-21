class_name BcAttack
extends CharacterBody3D

const bullet_scene = preload("res://game/entities/heroes/specifics/bc/bc_attack.tscn")

const SPEED: float = 100.0

var id: int
var direction: Vector2
var lifespan: float = 3
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	bullet.add_collision_exception_with(hero)
	var dirn: Vector2 = \
		target - Vector2(
			hero.global_position.x,
			hero.global_position.z)
	
	var manager: UnitManager = hero.unit_manager
	bullet.init(
		manager.derivatives_count, dirn, hero)
	manager.add_child(bullet)
	manager.derivatives_count += 1

func init(b_id: int, dirn: Vector2, h: Hero):
	id = b_id
	direction = dirn
	hero = h
	position = Vector3(position.x, 10, position.y)

func simulate(unit_states):
	var interactions = []
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
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider() is Hero:
			var target : Hero = collision.get_collider()
			interactions.append(func(): target.health -= 1)
			lifespan = -1	#remove
	
	lifespan -= delta
	if lifespan < 0:
		interactions.append(func(): queue_free())
	return interactions


func get_state():
	return {'id' : id,\
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan
		}
