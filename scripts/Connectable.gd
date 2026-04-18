extends Node2D

@export var max_connections := 2
@export var current_band := 1

func _ready():
	add_to_group("connectable")
