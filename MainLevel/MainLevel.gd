extends Node2D

signal change_extents(min_x, min_y, max_x, max_y)


func _ready():
	calculate_bounds()


func calculate_bounds():
	var rect = $MainLevel.get_used_rect()
	var cell_size = $MainLevel.cell_size

	emit_signal("change_extents", 0, 0, rect.size.x * cell_size.x, rect.size.y * cell_size.y)
