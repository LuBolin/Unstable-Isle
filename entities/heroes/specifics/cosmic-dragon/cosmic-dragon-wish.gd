class_name CosmicDragonWish
extends ShapeCast3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_wish.tscn")

const SPEED: float = 100.0

var id: int
var type = "CosmicDragonWish"
var direction: Vector2
var lifespan: float = 10
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
	direction = dirn
	hero = h
	var random_direction = Vector2.from_angle(randf() * 2 * PI) * randi_range(100, 500)
	global_position = hero.global_position + Vector3(random_direction.x, 0, random_direction.y)

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()
	
	lifespan -= delta
	if lifespan < 10:
		$MeshInstance3D.show()
	else:
		$MeshInstance3D.hide()
	
	if lifespan < 0:
		var node = self
		var parent = get_parent()
		var count = get_collision_count()
		for i in range(count):
			var target = get_collider(i)
			print(target)
			if not target.get("health") == null:
				interactions.append(func(): target.health += 1)
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,\
		'lifespan' : lifespan,
		}
