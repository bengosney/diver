extends Polygon2D

export(int) var swarm_size = 5
export(PackedScene) var swarm_scene
export(int) var min_scale = 0.25
export(int) var max_scale = 1

var swarm = []

var _triangles: Array
var _cumulative_area: Array

var _rand: RandomNumberGenerator


func _ready():
	_rand = RandomNumberGenerator.new()
	_rand.randomize()

	init_area()
	_spawn_swarm()

	self.color = Color(0, 0, 0, 0)


func _spawn_swarm():
	for i in range(swarm_size):
		var swarm_instance = swarm_scene.instance()

		swarm_instance.position = get_random_point()

		var rand_scale = _rand.randf_range(min_scale, max_scale)
		swarm_instance.set("scale", rand_scale)
		swarm_instance.set("size_scale", rand_scale)

		swarm.append(swarm_instance)
		add_child(swarm_instance)


func init_area():
	var triangle_points = Geometry.triangulate_polygon(polygon)
	var triangle_count: int = triangle_points.size() / 3

	_triangles.resize(triangle_count)
	_cumulative_area.resize(triangle_count)
	_cumulative_area[-1] = 0

	for i in range(triangle_count):
		var a: Vector2 = polygon[triangle_points[3 * i + 0]]
		var b: Vector2 = polygon[triangle_points[3 * i + 1]]
		var c: Vector2 = polygon[triangle_points[3 * i + 2]]

		_triangles[i] = [a, b, c]
		_cumulative_area[i] = _cumulative_area[i - 1] + triangle_area(a, b, c)


func get_random_point() -> Vector2:
	var t = _cumulative_area.bsearch(_rand.randf() * _cumulative_area[-1])

	return random_triangle_point(_triangles[t][0], _triangles[t][1], _triangles[t][2])


func random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	return a + sqrt(randf()) * (-a + b + randf() * (c - b))


func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))
