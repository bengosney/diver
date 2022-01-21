extends CanvasLayer

signal reset


func set_buoyancy(buoyancy):
	$Container/Buoyancy.set_value(buoyancy)


func setup(min_buoyancy, max_buoyancy, max_air):
	$Container/Air.set_max(max_air)
	$Container/Buoyancy.set_min(min_buoyancy)
	$Container/Buoyancy.set_max(max_buoyancy)


func set_air(air):
	$Container/Air.set_value(air)


func _on_reset_button_pressed():
	emit_signal("reset")
