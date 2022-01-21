extends CanvasLayer


func set_buoyancy(buoyancy):
	$GaugeContainer/Buoyancy.set_value(buoyancy)


func setup(min_buoyancy, max_buoyancy, max_air):
	$GaugeContainer/Air.set_max(max_air)
	$GaugeContainer/Buoyancy.set_min(min_buoyancy)
	$GaugeContainer/Buoyancy.set_max(max_buoyancy)


func set_air(air):
	$GaugeContainer/Air.set_value(air)


func set_pickups(collected, total):
	$Pickups.text = "Pickups: " + str(collected) + " of " + str(total)


func set_won(won):
	if won:
		$WonText.visible_characters = -1
	else:
		$WonText.visible_characters = 0
