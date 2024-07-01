class_name CosmicDragonBody
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_body.tscn")

const SPEED: float = 150.0
const tag_radius = 30

var id: int
var type = "CosmicDragonBody"
var direction: Vector2
var hero : Hero
var selected = false

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
	if selected:
		$Base/Ring.show()
	else:
		$Base/Ring.hide()
	var dirn: Vector3 = hero.global_position - global_position
	if dirn.length() > tag_radius:
		direction = Vector2(dirn.x, dirn.z)
		var delta = get_physics_process_delta_time()
		velocity = dirn.normalized() * SPEED
		var collision = move_and_collide(velocity * delta)
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,
		}
