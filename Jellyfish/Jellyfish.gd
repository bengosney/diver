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
		var dir = (-rel.normalized()) * 2
		apply_central_impulse(dir)


func _physics_process(_delta):
	var colliders = self.get_colliding_bodies()
	if len(colliders) > 0:
		for collider in colliders:
			if collider.is_in_group("player"):
				emit_signal("hit_player", self, 1)
