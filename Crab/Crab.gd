extends KinematicBody2D

export(int) var gravity = 800
export(int) var buoyancy = 0
export(int) var speed = 50
export(float, 0, 1.0) var acceleration = 0.25
export(float, 0, 1.0) var friction = 0.01

var velocity = Vector2.ZERO
var direction = "LEFT"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func turn_around():
	if direction == "LEFT":
		direction = "RIGHT"
	else:
		direction = "LEFT"


func walk():
	if not is_on_floor():
		return

	if is_on_wall():
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
	walk()
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)
