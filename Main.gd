extends Node2D


func _ready():
	var min_buoy = $Player.min_buoy - $Player.gravity
	var max_buoy = $Player.max_buoy - $Player.gravity

	$HUD.setup(min_buoy, max_buoy, $Player.starting_air)


func _process(_delta):
	var buoyancy = $Player.buoyancy - $Player.gravity
	$HUD.set_buoyancy(buoyancy)
	$HUD.set_air($Player.air)


func _on_HUD_reset():
	print("reset")
	$Player.reset()


func _on_MainLevel_change_extents(min_x, min_y, max_x, max_y):
	$Player.set_camera_extents(min_x, min_y, max_x, max_y)
