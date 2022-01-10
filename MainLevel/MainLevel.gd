extends Node2D

signal change_extents(top, left, right, bottom)


func _ready():
	calculate_bounds()


func calculate_bounds():
	var map_limits = $MainLevel.get_used_rect()
	var map_cellsize = $MainLevel.cell_size
	var limit_left = map_limits.position.x * map_cellsize.x
	var limit_right = map_limits.end.x * map_cellsize.x
	var limit_top = map_limits.position.y * map_cellsize.y
	var limit_bottom = map_limits.end.y * map_cellsize.y

	emit_signal("change_extents", limit_top, limit_left, limit_right, limit_bottom)


func calculate_boundsy():
	var rect = $MainLevel.get_used_rect()
	var cell_size = $MainLevel.cell_size

	emit_signal("change_extents", 0, 0, rect.end.x * cell_size.x, rect.end.y * cell_size.y)