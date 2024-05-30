class_name GroundChunk
extends RigidBody3D

enum CHUNK_STATE {
	Stable,
	Unstable,
	Crumbled
}

@onready var mesh_instance = $GroundMesh

@export var texture_pass: Shader
@export var outline_pass: Shader
@export var island_text: Texture2D

var arena_controller: ArenaController
var index_in_parent: int
var polygon: PackedVector2Array
var state: CHUNK_STATE = CHUNK_STATE.Stable :
	set(new_state):
		if new_state <= state:
			return
		state = new_state
		if new_state != CHUNK_STATE.Stable:
			if arena_controller and index_in_parent != null:
				arena_controller.chunk_states[index_in_parent] = new_state
		if new_state == CHUNK_STATE.Unstable:
			# simulate to turn red
			self.hit(0)
		elif new_state == CHUNK_STATE.Crumbled:
			self.crumble()

func _ready():
	self.set_freeze_enabled(true)

func initialize(arena: ArenaController, index: int):
	arena_controller = arena
	index_in_parent = index
	$IndexLabel.set_text(str(index))


func set_shape(poly: PackedVector2Array, thickness: float = 16.0):
	self.polygon = poly
	
	# Calculate the centroid of the polygon
	var centroid = Vector2()
	for i in range(poly.size()):
		centroid += poly[i]
	centroid /= poly.size()

	# Create a SurfaceTool to build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Define the number of vertices in the polygon
	var num_vertices = poly.size()

	# Define arrays for top and bottom vertices
	var top_vertices = []
	var bottom_vertices = []

	# Generate top and bottom vertices, adjusted by the centroid
	const axis: Vector3 = Vector3(0, 1, 0) # Height in Y axis
	for i in range(num_vertices):
		var vertex = Vector3(poly[i].x - centroid.x, 0, poly[i].y - centroid.y)
		top_vertices.append(vertex)
		bottom_vertices.append(vertex - axis * thickness)

	# Create top face (counter-clockwise order)
	for i in range(1, num_vertices - 1):
		st.set_normal(Vector3(0, 1, 0))
		st.add_vertex(top_vertices[0])
		st.set_normal(Vector3(0, 1, 0))
		st.add_vertex(top_vertices[i])
		st.set_normal(Vector3(0, 1, 0))
		st.add_vertex(top_vertices[i + 1])

	# Create bottom face (clockwise order)
	for i in range(1, num_vertices - 1):
		st.set_normal(Vector3(0, -1, 0))
		st.add_vertex(bottom_vertices[0])
		st.set_normal(Vector3(0, -1, 0))
		st.add_vertex(bottom_vertices[i + 1])
		st.set_normal(Vector3(0, -1, 0))
		st.add_vertex(bottom_vertices[i])

	# Create side faces
	for i in range(num_vertices):
		var next_i = (i + 1) % num_vertices

		# Calculate normals for the side faces
		var normal = (top_vertices[next_i] - top_vertices[i]
			).cross(bottom_vertices[i] - top_vertices[i]).normalized()
		
		# First triangle of the quad
		st.set_normal(normal)
		st.add_vertex(top_vertices[i])
		st.set_normal(normal)
		st.add_vertex(bottom_vertices[i])
		st.set_normal(normal)
		st.add_vertex(top_vertices[next_i])

		# Second triangle of the quad
		st.set_normal(normal)
		st.add_vertex(top_vertices[next_i])
		st.set_normal(normal)
		st.add_vertex(bottom_vertices[i])
		st.set_normal(normal)
		st.add_vertex(bottom_vertices[next_i])

	# Finish the mesh
	st.index()
	var mesh = st.commit()
	
	mesh_instance.mesh = mesh
	# collider for raycast on click
	mesh_instance.create_trimesh_collision()
	# StaticBody -> ConcavePolygonShape3D
	var collider = mesh_instance.get_child(0).get_child(0)
	mesh_instance.get_child(0).queue_free()
	collider.reparent(self)

	# unique instance per mesh
	var new_mat = func ():
		var mat = StandardMaterial3D.new()
		var text = ShaderMaterial.new()
		text.set_shader(texture_pass)
		text.set_shader_parameter("texture_albedo", island_text)
		mat.set_next_pass(text)
		return mat
	mesh_instance.mesh.surface_set_material(0, new_mat.call())

	# Calculate the position to place the mesh in the scene
	var position = Vector3(centroid.x, 0, centroid.y)
	self.global_position = position
	
	mesh_instance.set_meta("polygon", poly)

func crumble():
	if state != CHUNK_STATE.Crumbled:
		state = CHUNK_STATE.Crumbled
	# self.set_process_mode(PROCESS_MODE_ALWAYS)
	self.set_freeze_enabled(false)
	var mat = mesh_instance.get_active_material(0) # standard material
	var texture = mat.next_pass # texture shader
	texture.set_next_pass(ShaderMaterial.new())
	var outline = texture.next_pass
	outline.set_shader(outline_pass.duplicate())
	
	# boost downwards
	apply_central_force(Vector3(0,randf_range(-1.0, 1.0),0) * 25.0)
	var random_angular_force = Vector3(
		randf_range(-1, 1),
		randf_range(-1, 0.5), # less upwards force, if any
		randf_range(-1, 1)
	) * 5.0
	# requires inertia to be set
	apply_torque_impulse(random_angular_force)
	
	var timer = Timer.new()
	timer.name = "QueueFree countdown"
	timer.wait_time = 25.0
	timer.one_shot = true
	add_child(timer)
	# timer.timeout.connect(func(): self.queue_free())
	timer.timeout.connect(func(): self.set_process(false))
	timer.start()

func hit(strength = 1):
	state += strength
	if state >= CHUNK_STATE.Crumbled:
		crumble()
	else:
		var mat = mesh_instance.get_active_material(0) # standard material
		var texture = mat.next_pass # texture shader
		# red tint
		texture.set_shader_parameter("tint", Vector4(0.5,0,0,0.2))
		mesh_instance.global_position -= Vector3(0, 5, 0)

const min_crumble_delay = 0.1
const max_crumble_delay = 5.0
func radial_crumble(crumble_radius: float):
	if state == CHUNK_STATE.Crumbled:
		return
	var enclosed = true
	for point in self.polygon:
		if not Geometry2D.is_point_in_circle(
			point, Vector2.ZERO, crumble_radius):
			enclosed = false
			break
	if not enclosed:
		var crumble_countdown = Timer.new()
		add_child(crumble_countdown)
		crumble_countdown.name = "Crumble countdown"
		crumble_countdown.set_one_shot(true)
		crumble_countdown.start(randf_range(min_crumble_delay, max_crumble_delay))
		crumble_countdown.timeout.connect(self.crumble)
