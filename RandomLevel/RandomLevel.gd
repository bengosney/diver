extends Node2D

export(int) var level_seed = 1
export(int) var chest_count = 1

var _rng = RandomNumberGenerator.new()
var _chest = preload("res://Chest/Chest.tscn")

onready var astar = AStar2D.new()


func vec_to_grid(vec: Vector2, cell_size: Vector2):
	var x = floor(vec.x / cell_size.x) * cell_size.x
	var y = (floor(vec.y / cell_size.x) * cell_size.y) + cell_size.y

	return Vector2(x, y)


func rng_vec(extents: Vector2):
	return Vector2(_rng.randf_range(0, extents.x), _rng.randf_range(0, extents.y))


func id(point: Vector2):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b


func build_astar():
	var map = $Navigation2D/TileMap
	var map_size = Vector2(80, 40)
	var map_extents = map.cell_size * map_size

	var used_cells = map.get_used_cells_by_id(2)

	for cell in used_cells:
		astar.add_point(id(cell), cell, 1.0)

	for cell in used_cells:
		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

	return astar


func _ready():
	init_level()


func join_caverns():
	var map = $Navigation2D/TileMap
	var empty_cells = map.get_used_cells_by_id(2)
	var groups = []
	var used = []

	for empty_cell in empty_cells:
		if used.has(empty_cell):
			continue

		var to_check = [empty_cell]
		var group = []

		while to_check.size() > 0:
			var cell = to_check.pop_front()
			if not group.has(cell):
				group.append(cell)
				used.append(cell)

				for d in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
					var n = cell + d
					if empty_cells.has(n):
						to_check.append(n)
		groups.append(group.size())

	for group in groups:
		if group.size() < 30:
			continue


func init_level():
	_rng.seed = level_seed
	var noise = OpenSimplexNoise.new()

	noise.seed = level_seed
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

	for x in range(2, 8):
		for y in range(2, 8):
			map.set_cell(x, y, 2)

	for x in range(0, map_size.x):
		map.set_cell(x, 0, true)
		map.set_cell(x, map_size.y - 1, true)

	for y in range(0, map_size.y):
		map.set_cell(0, y, true)
		map.set_cell(map_size.x - 1, y, true)

	join_caverns()

	map.update_dirty_quadrants()
	map.update_bitmask_region()

	var cells = map.get_used_cells_by_id(1)
	var from = $Player.position
	var chest_positions: Array = []

	var empty_cells = map.get_used_cells_by_id(2)
	var player_pos = map.world_to_map($Player.position)

	var astar = build_astar()
	for i in range(10):
		var path: Array = []
		var chest_pos: Vector2
		var new_chest = _chest.instance()
		var pos: Vector2
		var attempts = 0
		while len(path) == 0:
			if attempts > 50:
				print("bad seed")
				break
			attempts += 1

			pos = empty_cells[randi() % empty_cells.size()]
			while empty_cells.has(pos + Vector2.DOWN):
				pos = pos + Vector2.DOWN

			var too_close = false
			for p in chest_positions:
				if pos.distance_to(p) < 4:
					too_close = true

			if not too_close:
				path = astar.get_point_path(id(player_pos), id(pos))

		draw_map_path(path)
		clear_path(path)
		chest_positions.append(pos)

		new_chest.position = map.map_to_world(pos + Vector2.DOWN) + new_chest.get_offset()
		new_chest.add_to_group("pickups")
		map.add_child(new_chest)


func clear_path(path: Array):
	var map = $Navigation2D/TileMap
	var empty_cells = map.get_used_cells_by_id(2)

	for p in path:
		var up = p + Vector2.UP
		var down = p + Vector2.DOWN
		if not empty_cells.has(up) and not empty_cells.has(down):
			map.set_cellv(up, 2)


func draw_map_path(path: Array):
	var new_line = Line2D.new()
	var points = []
	for p in path:
		points.append($Navigation2D/TileMap.map_to_world(p))
	new_line.points = points
	new_line.width = 3
	self.add_child(new_line)
