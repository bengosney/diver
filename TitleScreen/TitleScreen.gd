extends CanvasLayer

signal start_game


func _on_Button_pressed():
	emit_signal("start_game")


func _process(_delta):
	var cam = $Camera2D
	var map = $Node2D/TileMap
	var used = map.get_used_rect()
	var viewport = get_viewport()

	cam.limit_right = (used.end.x - 1) * map.cell_size.x
	cam.limit_bottom = (used.end.y - 1) * map.cell_size.y

	var tile_offset = (viewport.size.x - (used.end.x * (map.cell_size.x - 1))) / 2
	$Node2D/TileMap.position = Vector2(tile_offset, 0)
