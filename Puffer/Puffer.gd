extends KinematicBody2D

signal hit_player(node, dammage)

enum Directions { LEFT, RIGHT }

export(Directions) var starting_direction = Directions.LEFT
export(int) var view_distance = 75
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
	var distance = view_angle / 2
	var poly = PoolVector2Array(
		[Vector2(0, 0), Vector2(view_distance, -distance), Vector2(view_distance, distance)]
	)
	$View/ViewCone.set_polygon(poly)
	$Polygon2D.set_polygon(poly)


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


func _on_View_body_entered(body):
	if body.is_in_group("player"):
		puffed = true


func _on_View_body_exited(body):
	if body.is_in_group("player"):
		puffed = false
