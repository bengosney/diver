extends Node2D


func _on_TitleScreen_start_game():
	get_tree().change_scene("res://MainLevel/PlayableLevel.tscn")
