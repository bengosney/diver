extends Node2D

const BACKGROUND_LAYER = 2
const FORGROUND_LAYER = 1

export(int) var level_seed = 1
export(int) var chest_count = 10
export(int) var cave_size = 30

var _rng = RandomNumberGenerator.new()
var _chest = preload("res://Chest/Chest.tscn")
var _spawner = preload("res://Swarm/Swarm.tscn")
var _puffer = preload("res://Puffer/Puffer.tscn")
var _jelly = preload("res://Jellyfish/Jellyfish.tscn")

var _pickups_total = 0
var _pickups_collected = 0

onready var astar = AStar2D.new()
onready var map = $TileMap


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
	var map_size = Vector2(80, 40)
	var map_extents = map.cell_size * map_size

	var used_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)

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

	$Player.starting_air = map.get_used_cells_by_id(BACKGROUND_LAYER).size() * 0.15

	var min_buoy = $Player.min_buoy - $Player.gravity
	var max_buoy = $Player.max_buoy - $Player.gravity

	$HUD.setup(min_buoy, max_buoy, $Player.starting_air)

	for pickup in get_tree().get_nodes_in_group("pickups"):
		_pickups_total += 1
		pickup.connect("pickup", self, "_pickup")

	$Player.connect("dead", self, "_on_Player_dead")
	$Player.connect("last_breath", self, "_on_Player_last_breath")
	$HUD.connect("restart_game", self, "_on_HUD_restart_game")
	$Sub.connect("player_entered", self, "_on_Sub_entered")

	$Player.start()


func _process(_delta):
	var buoyancy = $Player.buoyancy - $Player.gravity
	$HUD.set_buoyancy(buoyancy)
	$HUD.set_air($Player.air)
	$HUD.set_pickups(_pickups_collected, _pickups_total)


func _on_Sub_entered():
	if _pickups_collected == _pickups_total:
		$HUD.set_won(true, $Player.get_score())
		$Player.set_won()


func _on_Player_dead():
	$HUD.set_dead(true)


func _on_Player_last_breath(time):
	$HUD.fade_to_black(time)


func _on_HUD_restart_game():
	get_tree().change_scene("res://Main.tscn")


func _on_MainLevel_won():
	$HUD.set_won($MainLevel.won, $Player.get_score())
	$Player.set_won()


func _pickup():
	_pickups_collected += 1


func find_caves():
	var empty_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)
	var caves = []
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
		caves.append(group)
	return caves


func join_caves(caves):
	var player_cave = caves[0]
	var player_pos = map.world_to_map($Player.position)
	for cave in caves:
		if cave.has(player_pos):
			player_cave = cave
			break

	for cave in caves:
		if cave.size() <= cave_size or cave == player_cave:
			continue

		var from = _rand_element(player_cave)
		from.x = max(player_pos.x, from.x)
		from.y = max(player_pos.y, from.y)

		var to = _rand_element(cave)
		var cur = from
		while cur != to:
			map.set_cellv(cur - Vector2.UP, 2)
			map.set_cellv(cur, 2)
			map.set_cellv(cur + Vector2.UP, 2)
			cur = cur.move_toward(to, 1)


func _rand_element(thing):
	return thing[_rng.randi_range(0, thing.size() - 1)]


func spawn_creatures(caves: Array):
	var tile_offset = Vector2($TileMap.cell_size.x / 2, $TileMap.cell_size.y / 2)
	var empty_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)
	var big_caves = []
	var player_pos = map.world_to_map($Player.position)

	for cave in caves:
		if cave.size() >= cave_size and not cave.has(player_pos):
			big_caves.append(cave)

	var ocupied = []

	"""
	var cave = _rand_element(big_caves)
	for i in range(0, cave.size() / 5):
		var pos = _rand_element(cave)
		while ocupied.has(pos):
			pos = _rand_element(cave)

		var jelly = _jelly.instance()
		jelly.position = map.map_to_world(pos)
		jelly.add_to_group("enemies")
		ocupied.append(pos)
		map.add_child(jelly)
	"""

	var puffer_spawns = []
	for cave in big_caves:
		puffer_spawns.append_array(cave)

	for i in range(0, puffer_spawns.size() * 0.025):
		var pos = _rand_element(puffer_spawns)
		var has_room = false
		while ocupied.has(pos) or not has_room:
			pos = _rand_element(empty_cells)
			has_room = true
			for to_check in [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT]:
				if not empty_cells.has(pos + to_check):
					has_room = false

		var puff = _puffer.instance()
		puff.position = map.map_to_world(pos) + tile_offset
		puff.add_to_group("enemies")
		ocupied.append(pos)
		map.add_child(puff)


func spawn_chests():
	var from = $Player.position
	var chest_positions: Array = []

	var empty_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)
	var player_pos = map.world_to_map($Player.position)

	var astar = build_astar()
	for i in range(chest_count):
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

			pos = _rand_element(empty_cells)
			while empty_cells.has(pos + Vector2.DOWN):
				pos = pos + Vector2.DOWN

			var too_close = false
			for p in chest_positions:
				if pos.distance_to(p) < 4:
					too_close = true

			if not too_close and empty_cells.has(pos + Vector2.UP):
				path = astar.get_point_path(id(player_pos), id(pos))

		draw_map_path(path)
		clear_path(path)
		chest_positions.append(pos)

		new_chest.position = map.map_to_world(pos + Vector2.DOWN) + new_chest.get_offset()
		new_chest.add_to_group("pickups")
		map.add_child(new_chest)


func init_level():
	_rng.seed = level_seed
	var noise = OpenSimplexNoise.new()

	noise.seed = level_seed
	noise.octaves = 4
	noise.period = 20
	noise.persistence = 0.8

	var map_size = Vector2(80, 40)
	var map_extents = map.cell_size * map_size

	$Player.set_camera_extents(0, 0, map_extents.x, map_extents.y)

	map.clear()
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			var p = Vector2(x, y)
			var n = noise.get_noise_2dv(p)
			var layer_index = FORGROUND_LAYER if n > 0 else BACKGROUND_LAYER
			map.set_cellv(p, layer_index)

	for x in range(2, 8):
		for y in range(2, 8):
			map.set_cell(x, y, 2)

	for x in range(0, map_size.x):
		map.set_cell(x, 0, true)
		map.set_cell(x, map_size.y - 1, true)

	for y in range(0, map_size.y):
		map.set_cell(0, y, true)
		map.set_cell(map_size.x - 1, y, true)

	var caves = find_caves()
	join_caves(caves)

	var cells = map.get_used_cells_by_id(FORGROUND_LAYER)

	spawn_chests()
	spawn_creatures(caves)

	map.update_dirty_quadrants()
	map.update_bitmask_region()


func clear_path(path: Array):
	var empty_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)

	for p in path:
		var up = p + Vector2.UP
		var down = p + Vector2.DOWN
		map.set_cellv(up, 2)


func draw_map_path(path: Array):
	return
	var new_line = Line2D.new()
	var points = []
	for p in path:
		points.append($TileMap.map_to_world(p))
	new_line.points = points
	new_line.width = 3
	self.add_child(new_line)
