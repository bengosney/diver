extends Polygon2D

export(int) var swarm_size = 5

var jelly_scene = preload("res://Jellyfish/Jellyfish.tscn")
var jellies = []

var _triangles: PoolIntArray
var _cumulated_triangle_areas: Array

var _rand: RandomNumberGenerator


func _spawn_jellyfish():
	var min_x: int = 9999999
	var max_x: int = -9999999
	var min_y: int = 9999999
	var max_y: int = -9999999

	for p in polygon:
		min_x = min(p.x, min_x)
		max_x = max(p.x, max_x)
		min_y = min(p.y, min_y)
		max_y = max(p.y, max_y)

	for i in range(swarm_size):
		var jelly = jelly_scene.instance()

		jelly.position = Vector2(rand_range(min_x, max_x), rand_range(min_y, max_y))
		jelly.size_scale = rand_range(0.25, 1)

		jellies.append(jelly)
		add_child(jelly)


func _ready():
	_rand = RandomNumberGenerator.new()
	_rand.randomize()

	_spawn_jellyfish()

	self.color = Color(0, 0, 0, 0)
