class_name DwarfBomb
extends CharacterBody3D

@onready var core_explosion = $CoreExplosion
@onready var edge_explosion = $EdgeExplosion

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles

const bullet_scene = preload("res://entities/heroes/specifics/dwarf/dwarf_bomb.tscn")

const FUSE_DURATION = 2.5
const SPEED: float = 100.0

var id: int
var type = "DwarfBomb"
var direction: Vector2
var lifespan: float = FUSE_DURATION
var hero : Hero

@export var speed_curve: Curve

static func create(hero: Hero, target: Vector2):
	var bullet = bullet_scene.instantiate()
	var dirn: Vector2 = \
		target - Vector2(
			hero.global_position.x,
			hero.global_position.z)
	dirn = dirn.normalized()
	bullet.add_collision_exception_with(hero)
	
	var manager: UnitManager = hero.unit_manager
	var b_id = manager.add(bullet)
	bullet.init(b_id, dirn, hero)
	return bullet

var hits = []

func init(b_id: int, dirn: Vector2, h: Hero):
	id = b_id
	direction = dirn
	hero = h
	
	var dirn_v3: Vector3 = Vector3(direction.x, 0, direction.y)

func simulate(unit_states):
	var interactions = []
	global_position = unit_states['position']
	direction = unit_states['direction']
	var dirn: Vector3 = Vector3(direction.x, 0, direction.y)
	lifespan = unit_states['lifespan']
	var delta = get_physics_process_delta_time()

	var look_target = global_position + dirn.normalized()
	look_at(look_target)
	
	var speed = speed_curve.sample(1.0-(lifespan/FUSE_DURATION)) * SPEED
	
	velocity = dirn.normalized() * speed
	velocity.y -= Settings.GRAVITY * delta * 10
	# move_and_collide(velocity * delta)
	move_and_slide()
	
	if lifespan > 0 and lifespan - delta <= 0:
		explosion_particles.restart()
		
		# ground chunk states are only updatees from server side
		if hero.game_room.mutiplayer.is_server():
			var hits = []
			core_explosion.target_position = Vector3.ZERO
			core_explosion.force_shapecast_update()
			for target in core_explosion.collision_result:
				var collider = target['collider']
				if collider in hits:
					continue
				hits.append(collider)
				if collider is GroundChunk:
					#print("Crumble. ", collider)
					interactions.append(func(): collider.crumble())
				if collider.get("health"):
					interactions.append(func(): collider.health -= 2)
			edge_explosion.target_position = Vector3.ZERO
			edge_explosion.force_shapecast_update()
			for target in edge_explosion.collision_result:
				var collider = target['collider']
				if collider in hits:
					continue
				hits.append(collider)
				if collider is GroundChunk:
					#print("Hit. ", collider)
					interactions.append(func(): collider.hit())
				if collider.get("health"):
					interactions.append(func(): collider.health -= 1)

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
		'lifespan' : lifespan,
		}
