class_name ArenaController
extends Node3D

@export var ground_chunk: PackedScene

@onready var chunk_root = $ChunkRoot

# radius = 400
var delaunay_step = 25
var delaunay_noise = 20

var crumble_radius = Settings.ISLAND_RADIUS
var crumble_step_size = 10
var crumble_period = 5.0

var chunk_states: Array[GroundChunk.CHUNK_STATE] = []

func _ready():
	# start_game()
	pass

func init_island(seed):
	var sites = make_island(Settings.ISLAND_RADIUS,
		delaunay_step, delaunay_noise, seed)

	for i in range(len(sites)):
		var site = sites[i]
		var chunk: GroundChunk = ground_chunk.instantiate()
		chunk.initialize(self, i)
		chunk_root.add_child(chunk)
		chunk.set_shape(site.polygon)

	chunk_states.clear()
	chunk_states.resize(len(sites))
	chunk_states.fill(GroundChunk.CHUNK_STATE.Stable)

func start_game():
	if multiplayer.is_server():
		var crumble_timer = Timer.new()
		add_child(crumble_timer)
		crumble_timer.name = 'Crumble Timer'
		crumble_timer.wait_time = crumble_period
		crumble_timer.timeout.connect(self.crumble_step)
		crumble_timer.start()

func make_island(radius: float, step_size: float, 
	axis_variance: float = 30, seed = null):
	var rdm = RandomNumberGenerator.new()
	if seed is int:
		rdm.set_seed(seed)
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
	var borders_count = 0
	var rescued_count = 0
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

func crumble_step():
	crumble_radius -= crumble_step_size
	
	for chunk in chunk_root.get_children():
		chunk.radial_crumble(crumble_radius)

