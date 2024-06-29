class_name BcFirst
extends CharacterBody3D

const bullet_scene = preload("res://game/entities/heroes/specifics/bc/bc_first.tscn")

const SPEED: float = 200.0

var id: int
var type = "BcFirst"
var direction: Vector2
var lifespan: float = 5
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	bullet.add_collision_exception_with(hero)
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
	direction = dirn
	hero = h

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
			var stun = BcStun.new()
			stun.create(hero, stun.total_duration)
			#interactions.append(func(): target.apply_status(slow))
			target.apply_status(stun)
			lifespan = -1	#remove
	
	lifespan -= delta
	if lifespan < 0:
		interactions.append(func(): free())
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan
		}
