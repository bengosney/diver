extends Node

var _seed: int


func set_seed(new_seed):
	_seed = hash(new_seed)


func get_seed():
	if !_seed:
		print("rng")
		var r = RandomNumberGenerator.new()
		r.randomize()
		_seed = r.randi()

	return _seed
