extends RigidBody2D

signal hit_player(node, dammage)

var velocity = Vector2.ZERO
var move_to = Vector2.ZERO
var starting_position = Vector2.ZERO


func _ready():
	starting_position = position


func _on_Timer_timeout():
	var diff = position.y - starting_position.y
	if diff > 0:
		var rel = position - starting_position
		var dir = -rel.normalized()
		print("swim ", dir)
		apply_central_impulse(dir)
