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
		if cell == Vector2(5, 4):
			print("found player")
		if cell == Vector2(18, 4):
			print("found chest")
		if cell.y == 4:
			print(cell)

	for cell in used_cells:
		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

	return astar


func _ready():
	init_level()


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

	map.update_dirty_quadrants()
	map.update_bitmask_region()

	var cells = map.get_used_cells_by_id(1)
	var from = $Player.position
	var chest_positions = []

	var empty_cells = map.get_used_cells_by_id(2)

	var astar = build_astar()
	for i in range(1):
		var path: Array = []
		var chest_pos: Vector2
		var new_chest = _chest.instance()
		var pos: Vector2
		var attempts = 0
		while len(path) == 0:
			if attempts > 0:
				print("bad seed")
				break
			attempts += 1

			pos = empty_cells[randi() % empty_cells.size()]

			pos = rng_vec(map_extents)
			pos = $ColorRect.rect_position
			var map_pos = map.world_to_map(pos)
			if map.get_cellv(map_pos) == 2:
				var mov = Vector2.DOWN * map.cell_size.y
				while map.get_cellv(map_pos) == 2:
					pos = pos + mov
					map_pos = map.world_to_map(pos)
				pos = (pos - mov) - Vector2.UP

				chest_pos = vec_to_grid(pos, map.cell_size) + new_chest.get_offset()
				var too_close = false
				for c in chest_positions:
					if chest_pos.distance_to(c) < (max(map.cell_size.y, map.cell_size.x) * 4):
						too_close = true

				if not too_close:
					#path = $Navigation2D.get_simple_path(from, chest_pos, false)
					print(from, " : ", chest_pos)
					print(map.world_to_map(from), " - ", map.world_to_map(chest_pos))
					var a = id(map.world_to_map(from))
					#var b = id(map.world_to_map(from + (Vector2.RIGHT * 128)))
					var b = id(map.world_to_map(chest_pos) - Vector2.UP)
					print(a, " : ", b)
					path = astar.get_point_path(a, b)

		print(path)
		chest_positions.append(chest_pos)
		var new_line = Line2D.new()
		new_line.points = path
		new_line.width = 3
		self.add_child(new_line)

		new_chest.position = chest_pos
		new_chest.add_to_group("pickups")
		map.add_child(new_chest)
