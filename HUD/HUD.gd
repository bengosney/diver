extends CanvasLayer

signal reset


func set_buoyancy(buoyancy):
	$buoyancy_slider.value = buoyancy
	$Buoyancy.set_value(buoyancy)


func setup(min_buoyancy, max_buoyancy, max_air):
	$buoyancy_slider.min_value = min_buoyancy
	$buoyancy_slider.max_value = max_buoyancy

	$air_slider.min_value = 0
	$air_slider.max_value = max_air
	$air_slider.value = max_air
	$air_slider.step = max_air / 1000

	$Air.set_max(max_air)
	$Buoyancy.set_min(min_buoyancy)
	$Buoyancy.set_max(max_buoyancy)


func set_air(air):
	$air_slider.value = air
	$Air.set_value(air)


func _on_reset_button_pressed():
	emit_signal("reset")
