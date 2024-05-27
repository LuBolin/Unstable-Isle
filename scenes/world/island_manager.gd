extends Node3D

@export var ground_chunk: PackedScene

var mesh_root = null

var island_radius = 400
var delaunay_step = 40
var delaunay_noise = 20
#var delaunay_step = 25
#var delaunay_noise = 20
var mesh_seed = 33333

var crumble_step_size = 10
var crumble_radius = island_radius
var crumble_period = 15.0

var game_started = false

func _ready():
	start_game()

func _process(delta):
	pass

func _input(event):
	# right click will be for movement now
	return
	if not game_started:
		return
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_R:
				get_tree().reload_current_scene()
	elif event is InputEventMouseButton:
		if event.is_pressed() and \
			event.button_index == MOUSE_BUTTON_RIGHT:
				var mousePos = get_viewport().get_mouse_position()
				var camera_3d = get_viewport().get_camera_3d()
				var from = camera_3d.project_ray_origin(mousePos)
				var to = from + camera_3d.project_ray_normal(mousePos) * 1000
				var space = get_world_3d().direct_space_state
				var rayQuery = PhysicsRayQueryParameters3D.new()
				rayQuery.from = from
				rayQuery.to = to
				var result = space.intersect_ray(rayQuery)
				if not result.is_empty():
					var chunk = result['collider']
					# collider is already the rigidbody
					if chunk is GroundChunk:
						chunk.hit()

func start_game():
	game_started = true
	
	#var sites = make_island(island_radius, delaunay_step, 
	#delaunay_noise, mesh_seed)
	var sites = make_island(island_radius, delaunay_step, delaunay_noise)

	mesh_root = Node.new()
	mesh_root.name = "MeshRoot"
	add_child(mesh_root)

	for site in sites:
		var chunk = ground_chunk.instantiate()
		mesh_root.add_child(chunk)
		chunk.set_shape(site.polygon)
	
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
	
	for chunk in mesh_root.get_children():
		chunk.radial_crumble(crumble_radius)






### Archive
func get_polygon_area(vertices: PackedVector2Array) -> float:
	var area: float = 0.0
	var n: int = vertices.size()

	for i in range(n):
		var j = (i + 1) % n
		area += vertices[i].x * vertices[j].y
		area -= vertices[j].x * vertices[i].y

	return abs(area) / 2.0
