extends Area2D

signal pickup


func _ready():
	move_to_floor()


func move_to_floor():
	var space_state = get_world_2d().direct_space_state

	var offset = Vector2(0, 0)
	var down = position + (Vector2.DOWN * 100000)
	var result = space_state.intersect_ray(position, down, [self])
	if result:
		position = result.position + offset


func _on_Chest_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("pickup")
		queue_free()


func get_offset() -> Vector2:
	return Vector2(16, 0)
