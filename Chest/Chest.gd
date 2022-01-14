extends StaticBody2D


func _ready():
	move_to_floor()


func move_to_floor():
	var space_state = get_world_2d().direct_space_state

	var offset = Vector2(0, -12)
	var down = position + (Vector2.DOWN * 100)
	var result = space_state.intersect_ray(position, down, [self])
	if result:
		position = result.position + offset
