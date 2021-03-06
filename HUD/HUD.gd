extends CanvasLayer

signal restart_game


func _ready():
	$SeedLabel.bbcode_text = "[center]Seed: " + str(Global.get_seed()) + "[/center]"


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


func set_won(won, score):
	_set_game_over(won, "Job Done - " + str(score))


func set_dead(dead):
	_set_game_over(dead, "Dead")


func _set_game_over(on_off, text):
	$GameOver/GameOverText.bbcode_text = "[center]" + text + "[/center]"
	$GameOver.visible = on_off


func fade_to_black(time):
	$ColorRect.color.a = 0
	$ColorRect/FadeToBlack.wait_time = time / 255.0
	$ColorRect/FadeToBlack.start()


func _on_FadeToBlack_timeout():
	$ColorRect.color.a += (1.0 / 255.0)
	if $ColorRect.color.a > 1:
		$ColorRect/FadeToBlack.stop()


func _on_TryAgain_pressed():
	emit_signal("restart_game")
