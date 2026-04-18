extends Node2D

@export var valid_color := Color(0, 1, 0, 0.5)
@export var invalid_color := Color(1, 0, 0, 0.5)

var is_valid := false

@onready var sprite = $Sprite2D

func set_valid(valid: bool):
	is_valid = valid
	sprite.modulate = valid_color if valid else invalid_color

func _process(delta):
	scale = Vector2.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.05)
	
	#Debugging
func _draw():
	draw_circle(Vector2.ZERO, 50, Color(0, 1, 0, 0.2))
