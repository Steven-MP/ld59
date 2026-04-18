extends Node2D

@export var data_rate := 2.0
@export var max_storage := 100.0

var stored_data := 0.0

func _process(delta):
	stored_data += data_rate * delta
	
	if stored_data >= max_storage:
		GameState.game_over = true
