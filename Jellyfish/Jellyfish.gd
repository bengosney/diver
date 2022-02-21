extends RigidBody2D

signal hit_player(node, dammage)

export(float) var size_scale = 1

var velocity = Vector2.ZERO
var move_to = Vector2.ZERO
var starting_position = Vector2.ZERO

var damage = 1

onready var _rng = RandomNumberGenerator.new()


func _ready():
	starting_position = position
	var s = 0.5 * size_scale
	$body.scale = Vector2(s, s)
	$AnimatedSprite.scale = Vector2(s, s)
	var area_body = $body.duplicate(DUPLICATE_USE_INSTANCING)
	$Area2D.add_child(area_body)
	randomise_timeout()


func randomise_timeout():
	_rng.randomize()
	$Timer.wait_time = _rng.randf_range(0.5, 1.5)


func _on_Timer_timeout():
	var diff = position.y - starting_position.y
	if diff > 0:
		var rel = position - starting_position
		var dir = (-rel.normalized()) * 2
		apply_central_impulse(dir)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.slow(1)


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		body.slow(-1)
