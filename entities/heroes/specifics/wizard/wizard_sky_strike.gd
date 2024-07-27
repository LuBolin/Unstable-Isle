class_name WizardSkyStrike
extends Node3D

const bullet_scene = preload("res://entities/heroes/specifics/wizard/wizard_sky_strike.tscn")

@onready var sstrike_cast: ShapeCast3D = $ShapeCast3D
@onready var ray: MeshInstance3D = $Mesh/Ray

var id: int
var type = "WizardSkyStrike"
var target: Vector2
var lifespan: float = 1.5
var hero : Hero

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	var manager: UnitManager = hero.unit_manager
	var b_id = manager.add(bullet)
	bullet.init(b_id, target, hero)
	return bullet

func init(b_id: int, tgt: Vector2, h: Hero):
	id = b_id
	target = tgt
	global_position = Vector3(target.x, 0, target.y)
	hero = h

func simulate(unit_states):
	var interactions = []
	# global_position = unit_states['position']
	target = unit_states['direction']
	global_position = Vector3(target.x, 0, target.y)
	lifespan = unit_states['lifespan']
	
	var delta = get_physics_process_delta_time()
	
	lifespan -= delta
	ray.scale.x = lifespan / 1.7
	ray.scale.z = lifespan / 1.7
	if lifespan < 0:
		var node = self
		var parent = get_parent()
		
		var hits = []
		sstrike_cast.target_position = Vector3.ZERO
		sstrike_cast.force_shapecast_update()
		for target in sstrike_cast.collision_result:
			var collider = target['collider']
			if collider in hits or collider == hero:
				continue
			hits.append(collider)
			if collider.get("health"):
				interactions.append(func(): collider.health -= 3)
			if hero.game_room.mutiplayer.is_server() \
				and collider is GroundChunk:
				interactions.append(func(): collider.hit())
				
		interactions.append(func(): parent.remove_child(node); queue_free())
	return interactions


func get_state():
	return {'id' : id,\
		'type' : type, \
		'direction' : target,\
		'position' : global_position,\
		'lifespan' : lifespan
		}
