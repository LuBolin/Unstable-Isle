class_name BcAttack
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/bc/bc_attack.tscn")

const SPEED: float = 100.0

var id: int
var type = "BcAttack"
var direction: Vector2
var lifespan: float = 3
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	#bullet.get_node('MeshInstance3D').mesh.surface_get_material(0).set_albedo(Color(randf(), randf(), randf(), 1))
	#bullet.get_node('MeshInstance3D').position.y = randi_range(30, 100)
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
			interactions.append(func(): target.health -= 1)
			var slow = BcSlow.new()
			slow.create(hero, slow.total_duration)
			#interactions.append(func(): target.apply_status(slow))
			target.apply_status(slow)
			lifespan = -1	#remove
	
	lifespan -= delta
	if lifespan < 0:
		var node = self
		var parent = get_parent()
		interactions.append(func(): parent.remove_child(node); queue_free())
		#interactions.append(func(): free())
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan
		}
