extends Node2D

var total_received := 0.0

func _ready():
	add_to_group("earth")
	add_to_group("connectable") # important if Earth can receive signals
