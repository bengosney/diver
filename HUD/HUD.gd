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


func set_dead(dead):
	if dead:
		$GameOverText.visible_characters = -1
	else:
		$GameOverText.visible_characters = 0


func fade_to_black(time):
	$ColorRect.color.a = 0
	$ColorRect/FadeToBlack.wait_time = time / 255.0
	$ColorRect/FadeToBlack.start()


func _on_FadeToBlack_timeout():
	$ColorRect.color.a += (1.0 / 255.0)
	if $ColorRect.color.a > 1:
		$ColorRect/FadeToBlack.stop()
