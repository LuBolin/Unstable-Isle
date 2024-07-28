class_name CosmicDragonAttack
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_attack.tscn")

const SPEED: float = 100.0
const orbit_speed = 100

var id: int
var type = "CosmicDragonAttack"
var direction: Vector2
var lifespan: float = 10
var hero : Hero
var orbit_angle = 0 #degrees

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
	orbit_angle = dirn.angle() / 2 / PI * 360

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	orbit_angle = unit_states['orbit_angle']
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()
	#orbit around body
	orbit_angle += orbit_speed * delta
	var body = null
	var tail = null
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			body = child
			add_collision_exception_with(child)
		if child is CosmicDragonTail:
			add_collision_exception_with(child)
	#current orbit radius set by CosmicDragonOrbit status
	var radius = 100
	for status in hero.status_manager.get_children():
		if status is CosmicDragonOrbit:
			radius = status.orbit_radius
	if not body == null:
		var curr_vector3 = global_position - body.global_position
		var curr_vector2 = Vector2(curr_vector3.x, curr_vector3.z)
		var curr_radius = curr_vector2.length()
		#unit vector in direction with correct angle
		var vector_to_position = Vector2.from_angle(orbit_angle / 360 * 2 * PI)
		#vector of length of current radius
		var vector_to_angle = vector_to_position * curr_radius - curr_vector2
		#how fast orb moves into position
		var velocity_vector = vector_to_position * SPEED * delta * (radius - curr_radius) #damping
		var final_vector = vector_to_angle + velocity_vector
		velocity = Vector3(final_vector.x, 0, final_vector.y)
	
		var collision = move_and_collide(velocity * delta)
		if collision:
			if not collision.get_collider().get("health") == null:
				var target = collision.get_collider()
				interactions.append(func(): target.health -= 1)
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
		'lifespan' : lifespan,
		'orbit_angle' : orbit_angle
		}
