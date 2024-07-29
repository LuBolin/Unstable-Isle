class_name WizardAttack
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/wizard/wizard_attack.tscn")

const SPEED: float = 80.0

var id: int
var type = "WizardAttack"
var direction: Vector2
var lifespan: float = 4
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
	lifespan = unit_states['lifespan']
	
	var delta = get_physics_process_delta_time()
	
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
		if not collision.get_collider().get("health") == null:
			var target = collision.get_collider()
			interactions.append(func(): target.health -= 2)
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
