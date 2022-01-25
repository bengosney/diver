extends KinematicBody2D

signal hit_player(node, dammage)

enum Directions { LEFT, RIGHT }

export(Directions) var starting_direction = Directions.LEFT
export(int) var view_distance = 50
export(float) var view_angle = 100

var gravity = 800
var buoyancy = 800
var speed = 50
var acceleration = 0.25
var friction = 0.05

var velocity = Vector2.ZERO
var direction = Directions.LEFT

var players = []
var puffed = false


func _ready():
	direction = starting_direction
	_set_sprite_flip()
	players = get_tree().get_nodes_in_group("player")
	check_should_puff()


func draw_view_cone():
	var thing = view_angle / 2


func check_should_puff():
	for player in players:
		var dist = position.distance_to(player.get_global_position())
		if dist > view_distance:
			continue

		var deg = rad2deg(get_angle_to(player.get_global_position()))

		var to = view_angle / 2
		var from = -to

		if deg > min(to, from) and deg < max(to, from):
			puffed = true
			return

	puffed = false


func _set_sprite_flip():
	$AnimatedSprite.set_flip_h(direction == Directions.LEFT)


func turn_around():
	if direction == Directions.LEFT:
		direction = Directions.RIGHT
	else:
		direction = Directions.LEFT

	_set_sprite_flip()


func swim():
	if is_on_wall():
		turn_around()

	var dir = 0
	if direction == Directions.LEFT:
		dir -= 1
	if direction == Directions.RIGHT:
		dir += 1

	if dir != 0 and !puffed:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)


func _process(_delta):
	check_should_puff()
	if puffed:
		$AnimatedSprite.frame = 1
	else:
		$AnimatedSprite.frame = 0


func _physics_process(delta):
	velocity.y += (gravity - buoyancy) * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	swim()

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			emit_signal("hit_player", collision, 5)
