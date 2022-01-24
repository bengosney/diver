extends KinematicBody2D

export(int) var speed = 100
export(int) var jump_speed = -200
export(int) var gravity = 800

export(float, 0, 1.0) var friction = 0.01
export(float, 0, 1.0) var acceleration = 0.025
export(float, 0, 1.0) var buoyancy_acc = 0.25
export(float, 0, 1.0) var air_step = .1
export(int) var starting_air = 100
export(float) var breath = 0.1
export(float) var leek_factor = 0.25
export(float) var hit_timeout = 0.25

export(PackedScene) var bubble_scene

var velocity = Vector2.ZERO
var minmax = 0.05
var max_buoy = gravity * (1 + minmax)
var min_buoy = gravity * (1 - (minmax * 2))
var buoyancy_step = (max_buoy - min_buoy) / 15
var buoyancy = gravity - (buoyancy_step * 2)

var air = starting_air

var can_be_hit = true
var leaks = []


func _ready():
	$PlayerCamera.limit_smoothed = true
	$PlayerCamera.reset_smoothing()
	move_and_collide(Vector2.DOWN * 100)
	$HitTimer.wait_time = hit_timeout


func set_camera_extents(top, left, right, bottom):
	$PlayerCamera.limit_top = top
	$PlayerCamera.limit_left = left
	$PlayerCamera.limit_right = right
	$PlayerCamera.limit_bottom = bottom


func reset():
	air = starting_air


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

	$BuoyancyBubbles.emitting = (buoy == -1 && air > 0)

	if buoy != 0 and air > 0:
		var target = buoyancy + (buoy * buoyancy_step)
		if target > buoyancy:
			air = air - air_step

		buoyancy = lerp(buoyancy, max(min(target, max_buoy), min_buoy), buoyancy_acc)


func breath(delta):
	air = max(0, air - (breath * delta))


func leak(delta):
	var total_leeks = 0
	for l in leaks:
		total_leeks += l

	if total_leeks > 0:
		var leeked = (total_leeks * leek_factor) * delta

		buoyancy = max(0, buoyancy - leeked)


func _process(delta):
	breath(delta)
	leak(delta)


func _physics_process(delta):
	get_input()
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_MainLevel_hit_player(collision, dammage):
	if not can_be_hit:
		return

	can_be_hit = false
	var leek = floor((starting_air / 100) * dammage)

	var leek_instance = bubble_scene.instance()
	var pos = collision.position - self.position

	leek_instance.amount = dammage
	leek_instance.emitting = true
	leek_instance.position = pos
	leaks.append(dammage)
	$Leeks.add_child(leek_instance)
	$HitTimer.start()


func _on_HitTimer_timeout():
	can_be_hit = true
