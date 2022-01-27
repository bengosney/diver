extends RigidBody2D

signal hit_player(node, dammage)

export(float) var size_scale = 1

var velocity = Vector2.ZERO
var move_to = Vector2.ZERO
var starting_position = Vector2.ZERO

var damage = 1


func _ready():
	starting_position = position
	var s = 0.5 * size_scale
	$body.scale = Vector2(s, s)
	$AnimatedSprite.scale = Vector2(s, s)
	randomise_timeout()


func randomise_timeout():
	$Timer.wait_time = rand_range(0.5, 1.5)


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
				emit_signal("hit_player", self, damage)
