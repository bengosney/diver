extends CanvasLayer

signal reset


func set_buoyancy(buoyancy):
	$Buoyancy.set_value(buoyancy)


func setup(min_buoyancy, max_buoyancy, max_air):
	$Air.set_max(max_air)
	$Buoyancy.set_min(min_buoyancy)
	$Buoyancy.set_max(max_buoyancy)


func set_air(air):
	$Air.set_value(air)


func _on_reset_button_pressed():
	emit_signal("reset")
