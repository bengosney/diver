extends Control

export(float) var value = 100
export(bool) var limited = true

var _min = -121
var _max = 121


func move():
	var inc = (_max - _min) / 100.0
	var rot = _min + (inc * value)
	if limited:
		$Needle.rotation_degrees = max(_min, min(_max, rot))
	else:
		$Needle.rotation_degrees = rot


func _ready():
	move()


func _process(_delta):
	move()
