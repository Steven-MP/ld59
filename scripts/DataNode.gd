extends Node2D

@export var data_rate := 5.0   # per second
@export var max_storage := 100.0

var stored_data := 0.0

func _process(delta):
	stored_data += data_rate * delta
	stored_data = min(stored_data, max_storage)
