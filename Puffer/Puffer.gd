extends KinematicBody2D

signal hit_player(node, dammage)

enum Directions { LEFT, RIGHT }

export(Directions) var starting_direction = Directions.LEFT

var gravity = 800
var buoyancy = 800
var speed = 50
var acceleration = 0.25
var friction = 0.01

var velocity = Vector2.ZERO
var direction = Directions.LEFT


func _ready():
	direction = starting_direction
	_set_sprit_flip()


func _set_sprit_flip():
	$AnimatedSprite.set_flip_h(direction == Directions.LEFT)


func turn_around():
	if direction == Directions.LEFT:
		direction = Directions.RIGHT
	else:
		direction = Directions.LEFT

	_set_sprit_flip()


func swim():
	if is_on_wall():
		turn_around()

	var dir = 0
	if direction == Directions.LEFT:
		dir -= 1
	if direction == Directions.RIGHT:
		dir += 1

	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)


func _physics_process(delta):
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	swim()

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			emit_signal("hit_player", collision, 5)
