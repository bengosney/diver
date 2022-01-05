extends KinematicBody2D


export (int) var speed = 100
export (int) var jump_speed = -200
export (int) var gravity = 800
export (int) var buoyancy_step = 25

var velocity = Vector2.ZERO
var minmax = 0.05
var max_buoy = gravity * (1 + minmax)
var min_buoy = gravity * (1 - (minmax * 2))
var buoyancy = min_buoy

export (float, 0, 1.0) var friction = 0.01
export (float, 0, 1.0) var acceleration = 0.025
export (float, 0, 1.0) var buoyancy_acc = 0.25

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
		
	var buoy = 0;
	if Input.is_action_pressed("buoyancy_inc"):
		buoy = 1;
	if Input.is_action_pressed("buoyancy_dec"):
		buoy = -1;
		
	if buoy != 0:
		var target = buoyancy + (buoy * buoyancy_step)
		
		buoyancy = lerp(buoyancy, max(min(target, max_buoy), min_buoy), buoyancy_acc)
	print(mod)
	

func _physics_process(delta):
	get_input()
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump") and false:
		if is_on_floor():
			velocity.y = jump_speed
