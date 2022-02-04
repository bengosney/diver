extends CanvasLayer


func _ready():
	pass


func _on_Left_button_down():
	Input.action_press("walk_left")


func _on_Left_button_up():
	Input.action_release("walk_left")


func _on_Right_button_down():
	Input.action_press("walk_right")


func _on_Right_button_up():
	Input.action_release("walk_right")


func _on_Inc_button_down():
	Input.action_press("buoyancy_inc")


func _on_Inc_button_up():
	Input.action_release("buoyancy_inc")


func _on_Dec_button_down():
	Input.action_press("buoyancy_dec")


func _on_Dec_button_up():
	Input.action_release("buoyancy_dec")
