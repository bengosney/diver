extends KinematicBody2D

signal hit_player(node, dammage)

enum Directions { LEFT, RIGHT }

export(Directions) var starting_direction = Directions.LEFT
export(int) var view_distance = 75
export(float) var view_angle = 100
export(float) var bounciness = 50

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
	set_view_cone()


func _set_sprite_flip():
	$AnimatedSprite.set_flip_h(direction == Directions.LEFT)


func set_view_cone():
	var x = view_distance
	if direction == Directions.LEFT:
		x = -x
	var y = view_angle / 2
	var poly = PoolVector2Array([Vector2(0, 0), Vector2(x, -y), Vector2(x, y)])
	$View/ViewCone.set_polygon(poly)


func turn_around():
	if direction == Directions.LEFT:
		direction = Directions.RIGHT
	else:
		direction = Directions.LEFT

	_set_sprite_flip()
	set_view_cone()


func swim():
	if is_on_wall() and not puffed:
		turn_around()

	var dir = 0
	if direction == Directions.LEFT:
		dir -= 1
	if direction == Directions.RIGHT:
		dir += 1

	if dir != 0 and !puffed:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, dir, friction)


func _process(_delta):
	if puffed:
		$AnimatedSprite.frame = 1
	else:
		$AnimatedSprite.frame = 0


func _physics_process(_delta):
	var starting_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			emit_signal("hit_player", collision, 1)
			var bounce = starting_velocity.bounce(collision.normal).normalized() * bounciness
			velocity = bounce

	swim()


func _on_View_body_entered(body):
	if body.is_in_group("player"):
		puffed = true


func _on_View_body_exited(body):
	if body.is_in_group("player"):
		puffed = false
