class_name CosmicDragonSelectedIndicator
extends CharacterBody3D

const bullet_scene = preload("res://entities/heroes/specifics/cosmic-dragon/cosmic-dragon_selected.tscn")

var id: int
var type = "CosmicDragonSelectedIndicator"
var hero : Hero
var direction: Vector2


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
	hero = h

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	#move towards body
	for child in hero.unit_manager.get_children():
		if child is CosmicDragonBody:
			if child.selected:
				global_position = child.global_position
				return interactions
		if child is CosmicDragonTail:
			if child.selected:
				global_position = child.global_position
				return interactions
	global_position = hero.global_position
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : direction,\
		'position' : global_position,
		}
