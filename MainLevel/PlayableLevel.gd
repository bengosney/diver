extends Node2D

signal reset_game


func _ready():
	var min_buoy = $Player.min_buoy - $Player.gravity
	var max_buoy = $Player.max_buoy - $Player.gravity

	$HUD.setup(min_buoy, max_buoy, $Player.starting_air)

	for player in get_tree().get_nodes_in_group("player"):
		player.connect("dead", self, "_player_dead")


func _process(_delta):
	var buoyancy = $Player.buoyancy - $Player.gravity
	$HUD.set_buoyancy(buoyancy)
	$HUD.set_air($Player.air)
	$HUD.set_pickups($MainLevel.pickups_collected, $MainLevel.pickups_total)


func _on_MainLevel_change_extents(top, left, right, bottom):
	$Player.set_camera_extents(top, left, right, bottom)


func _on_Player_dead():
	$HUD.set_dead(true)


func _on_Player_last_breath(time):
	$HUD.fade_to_black(time)


func _on_HUD_restart_game():
	get_tree().change_scene("res://Main.tscn")


func _on_MainLevel_won():
	$HUD.set_won($MainLevel.won, $Player.get_score())
	$Player.set_won()
