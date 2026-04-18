extends Node2D

@export var orbit_radius := 0.0
@export var orbit_speed := 0.1
@export var orbit_center: Node2D
@export var rotation_speed := 0.5
@export var radius := 50.0

var angle := 0.0

func _process(delta):
	if orbit_center:
		angle += orbit_speed * delta
		position = orbit_center.position + Vector2(cos(angle), sin(angle)) * orbit_radius
	
	rotation += rotation_speed * delta

func _ready():
	add_to_group("planets")
