extends KinematicBody2D

signal hit_player(node, dammage)

export(int) var gravity = 800
export(int) var buoyancy = 600
export(int) var speed = 50
export(float, 0, 1.0) var acceleration = 0.25
export(float, 0, 1.0) var friction = 0.01

export(bool) var walk_off = false

var velocity = Vector2.ZERO
var direction = "LEFT"
var walking = true


# Called when the node enters the scene tree for the first time.
func _ready():
	move_and_collide(Vector2.DOWN * 100)


func turn_around():
	if direction == "LEFT":
		direction = "RIGHT"
	else:
		direction = "LEFT"


func is_on_edge():
	var shape = $Body.get_shape()
	var width = shape.height + (shape.radius * 2)

	var offset = Vector2(width / 2, 0)

	var space_state = get_world_2d().direct_space_state
	var test
	if direction == "RIGHT":
		test = $Body.global_position + offset
	else:
		test = $Body.global_position - offset
	var down = test + (Vector2.DOWN * shape.height * 2)
	var result = space_state.intersect_ray(test, down, [self])

	if not result:
		return true

	return false


func walk():
	if not is_on_floor() or not walking:
		return

	if is_on_wall():
		turn_around()

	if not walk_off and is_on_edge():
		turn_around()

	var dir = 0
	if direction == "LEFT":
		dir -= 1
	if direction == "RIGHT":
		dir += 1

	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)


func _physics_process(delta):
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	walk()

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			emit_signal("hit_player", collision, 5)
			#walking = false
