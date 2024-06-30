class_name RangerAttack
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/ranger/ranger_attack.tscn")

const SPEED: float = 200.0

var id: int
var type = "RangerAttack"
var direction: Vector2
var lifespan: float = 5
var hero : Hero
var lock_on : int = -1
var turn_rate = 300

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
	lifespan = unit_states['lifespan']
	
	var delta = get_physics_process_delta_time()
	
	if not lock_on == null:
		var count =  $ShapeCast3D.get_collision_count()
		for i in range(count):
			var obj = $ShapeCast3D.get_collider(i)
			if obj is Hero:
				if obj.controller_id == lock_on:
					var to_lock_on = Vector2(obj.global_position.x, obj.global_position.z) - Vector2(global_position.x, global_position.z)
					direction = direction.move_toward(to_lock_on, turn_rate * delta)
	var dirn: Vector3 = Vector3(direction.x, 0, direction.y)
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
