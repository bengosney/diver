extends Control

export(float) var value = 100
export(float) var min_value = 0
export(float) var max_value = 100

var _min = -121
var _max = 121


func _get_mapped_value():
	return (value - min_value) / (max_value - min_value) * (_max - _min) + _min


func move():
	$Container/Needle.rotation_degrees = max(_min, min(_max, _get_mapped_value()))


func _ready():
	move()


func _process(_delta):
	move()


func set_min(new_min):
	self.min_value = new_min


func set_max(new_max):
	self.max_value = new_max


func set_value(new_value):
	self.value = new_value
