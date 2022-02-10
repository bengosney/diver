extends KinematicBody2D

signal dead
signal last_breath(time)

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

export(bool) var start_on_floor = true
export(bool) var has_light = true
export(bool) var has_physics = true

export(float, 0.01, 10) var zoom = 1

var bubble_scene = preload("res://Player/LeekBubbles.tscn")

var velocity = Vector2.ZERO
var minmax = 0.05
var max_buoy = gravity * (1 + minmax)
var min_buoy = gravity * (1 - (minmax * 2))
var buoyancy_step = (max_buoy - min_buoy) / 15
var buoyancy = gravity - (buoyancy_step * 2)

var air = starting_air

var can_be_hit = true
var leaks = []
var is_dead = false
var _has_won = false


func _ready():
	$PlayerCamera.limit_smoothed = true
	$PlayerCamera.reset_smoothing()
	$HitTimer.wait_time = hit_timeout
	if start_on_floor:
		move_and_collide(Vector2.DOWN * 100)

	$Light2D.enabled = has_light

	get_tree().get_root().connect("size_changed", self, "set_camera_zoom")


func set_won():
	_has_won = true


func set_camera_zoom():
	pass


func set_camera_extents(top, left, right, bottom):
	$PlayerCamera.limit_top = top
	$PlayerCamera.limit_left = left
	$PlayerCamera.limit_right = right
	$PlayerCamera.limit_bottom = bottom


func reset():
	air = starting_air


func get_score():
	return air


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
	var used = breath * delta
	if used > air:
		buoyancy = max(0, buoyancy - (used - air))
	air = max(0, air - used)


func leak(delta):
	var total_leeks = 0
	for l in leaks:
		total_leeks += l

	if total_leeks > 0:
		var leeked = (total_leeks * leek_factor) * delta

		if buoyancy <= min_buoy:
			air = max(0, air - (leeked * .5))

		buoyancy = max(min_buoy, buoyancy - leeked)


func _process(delta):
	$PlayerCamera.zoom = Vector2(zoom, zoom)
	if not _has_won:
		breath(delta)
		leak(delta)

		if air == 0 and buoyancy <= min_buoy and $LastBreath.is_stopped() and !is_dead:
			print("last breath")
			emit_signal("last_breath", $LastBreath.wait_time)
			$LastBreath.start()


func _physics_process(delta):
	if not has_physics:
		return

	if not is_dead and not _has_won:
		get_input()
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI / 4, false)

	var push = 1

	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bouncy"):
			var dir = -position.direction_to(collision.collider.position).normalized()
			velocity = velocity + (dir * 25)

		if collision.collider.is_in_group("enemies"):
			#if collision.collider.damage > 0:
			#print("hit enemy")
			pass


func _on_MainLevel_hit_player(collision, dammage):
	if not can_be_hit:
		return

	hit(collision, dammage)


func hit(collision, dammage):
	$AnimatedSprite.self_modulate = Color(1, 1, 1, 0.5)

	can_be_hit = false
	var leek = floor((starting_air / 100) * dammage)

	var leek_instance = bubble_scene.instance()
	var pos = collision.position - self.position

	leaks.append(dammage)

	if len(leaks) < 20:
		leek_instance.amount = dammage
		leek_instance.emitting = true
		leek_instance.position = pos
		$Leeks.add_child(leek_instance)

	$HitTimer.start()


func _on_HitTimer_timeout():
	can_be_hit = true
	$AnimatedSprite.self_modulate = Color(1, 1, 1, 1)


func _on_LastBreath_timeout():
	emit_signal("dead")
	is_dead = true
	$AnimatedSprite.playing = false
	var bubbles = get_tree().get_nodes_in_group("player_bubbles")
	for bubble in bubbles:
		bubble.emitting = false
