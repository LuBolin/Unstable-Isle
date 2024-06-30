class_name ArenaController
extends Node3D

@export var ground_chunk: PackedScene

@onready var chunk_root = $ChunkRoot
@onready var crumble_timer = $CrumbleTimer

const ArenaState = Serializables.ArenaState

# radius = 400
# var delaunay_step = 25
var delaunay_step = 50
var delaunay_noise = 20

var crumble_radius = Settings.ISLAND_RADIUS
var crumble_step_size = 20
var crumble_period = 20.0

var chunk_states: Array[GroundChunk.CHUNK_STATE] = []

func _ready():
	crumble_timer.wait_time = crumble_period
	crumble_timer.timeout.connect(self.crumble_step)

func init_island(_seed):
	for child in chunk_root.get_children(): child.queue_free()
	if multiplayer.is_server():
		crumble_timer.stop()
	
	crumble_radius = Settings.ISLAND_RADIUS
	
	var sites = make_island(Settings.ISLAND_RADIUS,
		delaunay_step, delaunay_noise, _seed)

	for i in range(len(sites)):
		var site = sites[i]
		var chunk: GroundChunk = ground_chunk.instantiate()
		chunk.initialize(self, i)
		chunk_root.add_child(chunk)
		chunk.set_shape(site.polygon)

	chunk_states.clear()
	chunk_states.resize(len(sites))
	chunk_states.fill(GroundChunk.CHUNK_STATE.Stable)
	

func make_island(radius: float, step_size: float, 
	axis_variance: float = 30, _seed = null):
	var rdm = RandomNumberGenerator.new()
	if _seed is int:
		rdm.set_seed(_seed)
	var origin = Vector3.ZERO
	var bounds = Rect2(origin.x - radius, origin.y - radius, 2 * radius, 2 * radius)
	var delaunay = DelaunayWrapper.new(bounds)

	var step_radius: float = radius + step_size/2 # padding for loop
	var variance = Vector2(axis_variance, axis_variance)
	
	while step_radius > 0:
		var step_angle = 0
		while step_angle < 2 * PI:
			# calculate point based on radius and angle
			# increase angle such that next point is step_size away
			# vary the current_point based on random value in variance
			# add point to delaunay
			var x = origin.x + step_radius * cos(step_angle)
			var y = origin.y + step_radius * sin(step_angle)
			var current_point = Vector2(x, y)
			
			var random_offset = Vector2(
				rdm.randf_range(-variance.x, variance.x),
				rdm.randf_range(-variance.y, variance.y)
			)
			current_point += random_offset
			
			delaunay.add_point(current_point)
			
			step_angle += step_size / step_radius
			
		step_radius -= step_size
	
	var triangles = delaunay.triangulate()
	
	var sites = delaunay.make_voronoi(triangles)
	#var borders_count = 0
	#var rescued_count = 0
	var bounding_circle = delaunay.make_bound_circle(32)
	
	var site_count = sites.size()
	var to_erase = []
	for site in sites:
		var cropped_polygon = delaunay.circle_crop(site, bounding_circle)
		if cropped_polygon.size() > 2: # valid polygon
			site.polygon = cropped_polygon
		else:
			to_erase.append(site)
			site_count -= 1
	for site in to_erase:
		sites.erase(site)
	print("Site count: ", site_count)
	return sites

# Server Functions
func start_round():
	if multiplayer.is_server():
		crumble_timer.start()
		
		# random initial destruction
		var allowed_destruction_radius = 0.5 * Settings.ISLAND_RADIUS
		var destruction_hit_radius = 0.08 * Settings.ISLAND_RADIUS
		
		var angle = randf_range(0, 2.0 * PI)
		var hit_count = randi_range(2, 5)
		var angle_offset = (2.0 * PI)/hit_count
		for i in range(hit_count):
			var r = randf_range(destruction_hit_radius * 2, allowed_destruction_radius)
			var x = r * cos(angle)
			var z = r * sin(angle)
			var point = Vector3(x, 0, z)
			hit_island(point, destruction_hit_radius)
			hit_island(point, destruction_hit_radius / 2.0) # further destroy the middle
			angle += angle_offset * randf_range(0.9, 1.1)

func crumble_step():
	crumble_radius -= crumble_step_size
	
	for chunk in chunk_root.get_children():
		chunk.radial_crumble(crumble_radius)

# Client Functions
func update_state(arena_state: ArenaState):
	var chunks = arena_state.chunks
	for i in len(chunks):
		var c: GroundChunk = chunk_root.get_child(i)
		c.state = chunks[i]

func hit_island(target: Vector3, radius: int):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	query.shape.radius = radius
	query.set_transform(Transform3D(Basis(), target))
	
	var collision = space_state.intersect_shape(query)
	for result in collision:
		var c = result['collider']
		if c is GroundChunk:
			print(c)
			c.hit()

