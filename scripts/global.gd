extends Node

var _seed: int


func set_seed(new_seed):
	_seed = hash(new_seed)


func get_seed():
	if !_seed:
		_seed = hash(OS.get_date())

	return _seed
