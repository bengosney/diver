extends Node

var _seed: int


func set_seed(new_seed: int):
	_seed = new_seed


func get_seed():
	if !_seed:
		var r = RandomNumberGenerator.new()
		r.randomize()
		_seed = r.randi()

	return _seed
