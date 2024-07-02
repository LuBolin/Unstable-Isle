class_name CosmicDragonTail
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_tail.tscn")

const SPEED: float = 100.0
const tag_radius = 30

var id: int
var type = "CosmicDragonTail"
var direction: Vector2
var hero : Hero
var selected = false
#transfer health loss to main hero
var health: int = 20 :
	set(new_health):
		hero.health -= health - new_health

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
	#move towards body
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			var dirn: Vector3 = child.global_position - global_position
			if dirn.length() > tag_radius:
				direction = Vector2(dirn.x, dirn.z)
				var delta = get_physics_process_delta_time()
				velocity = dirn.normalized() * SPEED
				var collision = move_and_collide(velocity * delta)
			self.add_collision_exception_with(child)
			child.add_collision_exception_with(self)
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,
		}
