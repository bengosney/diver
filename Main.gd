extends Node2D

const RANDOM_LEVEL = "res://RandomLevel/RandomLevel.tscn"


func start_game():
	get_tree().change_scene(RANDOM_LEVEL)


func _on_TitleScreen_start_game():
	start_game()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		start_game()


func _ready():
	#start_game()
	pass
