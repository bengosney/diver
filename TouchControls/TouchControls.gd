extends CanvasLayer

export(int) var button_size = 64


func _ready():
	for button in get_tree().get_nodes_in_group("buttons"):
		button.rect_min_size.x = button_size
		button.rect_min_size.y = button_size
