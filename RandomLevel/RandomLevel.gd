extends Node2D

var _rng = RandomNumberGenerator.new()
var _chest = preload("res://Chest/Chest.tscn")


func vec_to_grid(vec: Vector2, cell_size: Vector2, item_size: Vector2):
	var x = floor(vec.x / cell_size.x) * cell_size.x
	var y = floor(vec.y / cell_size.x) * cell_size.y

	return Vector2(x, y) + (item_size / 2)


func rng_vec(extents: Vector2):
	return Vector2(_rng.randf_range(0, extents.x), _rng.randf_range(0, extents.y))


func _ready():
	_rng.seed = 1
	var noise = OpenSimplexNoise.new()

	noise.seed = 1
	noise.octaves = 4
	noise.period = 20
	noise.persistence = 0.8

	var map = $Navigation2D/TileMap
	var map_size = Vector2(80, 40)
	var map_extents = map.cell_size * map_size

	print(map_extents)

	$Player.set_camera_extents(0, 0, map_extents.x, map_extents.y)

	map.clear()
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			var p = Vector2(x, y)
			var n = noise.get_noise_2dv(p)
			map.set_cellv(p, 1 if n > 0 else 2)

	for x in range(0, map_size.x):
		map.set_cell(x, 0, true)
		map.set_cell(x, map_size.y - 1, true)

	for y in range(0, map_size.y):
		map.set_cell(0, y, true)
		map.set_cell(map_size.x - 1, y, true)

	map.update_dirty_quadrants()
	map.update_bitmask_region()

	var from = $Player.position

	for i in range(5):
		var path: Array = []
		var chest_pos: Vector2
		var new_chest = _chest.instance()
		while len(path) == 0:
			chest_pos = vec_to_grid(rng_vec(map_extents), map.cell_size, new_chest.get_size())
			var to = chest_pos
			path = $Navigation2D.get_simple_path(from, to)

		var new_line = Line2D.new()
		new_line.points = path
		self.add_child(new_line)

		new_chest.position = chest_pos
		self.add_child(new_chest)
		print(i)
		new_chest.move_to_floor()
