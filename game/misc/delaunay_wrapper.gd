class_name DelaunayWrapper
extends Delaunay

func circle_crop(site: VoronoiSite, circle: PackedVector2Array) -> PackedVector2Array:
	var intersects = Geometry2D.intersect_polygons(site.polygon, circle)
	if intersects.size() > 1 : 
		print_debug("Warning: more than 1 intersect areas, return the first intersect area")
	elif intersects.size() == 0: # Bloin
		return []
	return intersects[0]
	
func make_bound_circle(roundness: int = 32):
	var radius = min(_rect.size.x, _rect.size.y) / 2.0
	var center = _rect.position + _rect.size / 2.0
	# print(center, radius)
	var bound_circle = PackedVector2Array()
	var angle_step  = 2.0 * PI / roundness
	
	for i in range(roundness):
		var angle = angle_step * i
		var x = center.x + radius * cos(angle)
		var y = center.y + radius * sin(angle)
		bound_circle.append(Vector2(x, y))
	
	return bound_circle


# taken from addon's example
static func show_triangle(canvas: Node, triangle: Delaunay.Triangle):
	var line = Line2D.new()
	var p = PackedVector2Array()
	p.append(triangle.a)
	p.append(triangle.b)
	p.append(triangle.c)
	p.append(triangle.a)
	line.points = p
	line.width = 1
	line.antialiased
	canvas.add_child(line)

static func show_site(canvas: Node, site: Delaunay.VoronoiSite):
####As Lines
#	var line = Line2D.new()
#	var p = site.polygon
#	p.append(p[0])
#	line.points = p
#	line.width = 1
#	line.default_color = Color.GREEN_YELLOW
#	add_child(line)

####As Polygons
	var polygon = Polygon2D.new()
	var p = site.polygon
	p.append(p[0])
	polygon.polygon = p
	polygon.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),0.5)
	polygon.z_index = -1
	canvas.add_child(polygon)
	
static func show_neighbour(canvas: Node, edge: Delaunay.VoronoiEdge):
	var line = Line2D.new()
	var points: PackedVector2Array
	var l = 6
	var s = lerp(edge.a, edge.b, 0.6)
	var dir = edge.a.direction_to(edge.b).orthogonal()
	points.append(s + dir * l)
	points.append(s - dir * l)
	line.points = points
	line.width = 1
	line.default_color = Color.CYAN
	canvas.add_child(line)
