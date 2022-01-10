extends KinematicBody2D

export(int) var speed = 100
export(int) var jump_speed = -200
export(int) var gravity = 800

export(float, 0, 1.0) var friction = 0.01
export(float, 0, 1.0) var acceleration = 0.025
export(float, 0, 1.0) var buoyancy_acc = 0.25
export(float, 0, 1.0) var air_step = .1
export(int) var starting_air = 100

var velocity = Vector2.ZERO
var minmax = 0.05
var max_buoy = gravity * (1 + minmax)
var min_buoy = gravity * (1 - (minmax * 2))
var buoyancy_step = (max_buoy - min_buoy) / 15
var buoyancy = gravity - (buoyancy_step * 2)

var air = starting_air


func _ready():
	$PlayerCamera.limit_smoothed = true
	$PlayerCamera.reset_smoothing()


func set_camera_extents(top, left, right, bottom):
	$PlayerCamera.limit_top = top
	$PlayerCamera.limit_left = left
	$PlayerCamera.limit_right = right
	$PlayerCamera.limit_bottom = bottom


func reset():
	air = 0


func get_input():
	var mod = .5
	if is_on_ceiling() or is_on_wall() or is_on_floor():
		mod = 1

	var dir = 0
	if Input.is_action_pressed("walk_right"):
		dir += mod
	if Input.is_action_pressed("walk_left"):
		dir -= mod
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)

	var buoy = 0
	if Input.is_action_pressed("buoyancy_inc"):
		buoy = 1
	if Input.is_action_pressed("buoyancy_dec"):
		buoy = -1

	if buoy != 0:
		var target = buoyancy + (buoy * buoyancy_step)
		if target > buoyancy:
			air = air - air_step

		buoyancy = lerp(buoyancy, max(min(target, max_buoy), min_buoy), buoyancy_acc)


func _process(delta):
	if position.y <= 0 and air < starting_air:
		var inc = ceil(starting_air - lerp(starting_air, air * .8, 1))
		print(inc)
		air += inc * delta
		if air >= starting_air:
			print("aired")


func _physics_process(delta):
	get_input()
	velocity.y += (gravity - buoyancy) * delta
	if position.y < 0:
		velocity.y = abs(velocity.y) / 3
	velocity = move_and_slide(velocity, Vector2.UP)
