extends Node2D

signal change_extents(top, left, right, bottom)
signal hit_player(node, dammage)
signal pickup
signal won

var pickups_total = 0
var pickups_collected = 0

var won = false


func _ready():
	calculate_bounds()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("hit_player", self, "_hit_player")

	for pickup in get_tree().get_nodes_in_group("pickups"):
		pickups_total += 1
		pickup.connect("pickup", self, "_pickup")


func _pickup():
	pickups_collected += 1


func calculate_bounds():
	var map_limits = $MainLevel.get_used_rect()
	var map_cellsize = $MainLevel.cell_size
	var limit_left = map_limits.position.x * map_cellsize.x
	var limit_right = map_limits.end.x * map_cellsize.x
	var limit_top = map_limits.position.y * map_cellsize.y
	var limit_bottom = map_limits.end.y * map_cellsize.y

	emit_signal("change_extents", limit_top, limit_left, limit_right, limit_bottom)


func _hit_player(node, dammage):
	emit_signal("hit_player", node, dammage)


func _on_Sub_player_entered():
	if pickups_collected >= pickups_total and not won:
		won = true
		emit_signal("won")
