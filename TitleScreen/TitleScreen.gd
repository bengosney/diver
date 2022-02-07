extends CanvasLayer

signal start_game


func _on_Button_pressed():
	emit_signal("start_game")


func _ready():
	var noise = OpenSimplexNoise.new()

	noise.seed = 1
	noise.octaves = 4
	noise.period = 20
	noise.persistence = 0.8

	$Node2D/TileMap.clear()
	for x in range(0, 40):
		for y in range(0, 20):
			var p = Vector2(x, y)
			var n = noise.get_noise_2dv(p)
			$Node2D/TileMap.set_cellv(p, n > 0, false, false, true)
