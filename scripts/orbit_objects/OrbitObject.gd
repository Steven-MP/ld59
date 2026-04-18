extends Node2D

@export var parent_body: Node2D
@export var orbit_radius := 100.0
@export var orbit_speed := 1.0

var angle := 0.0

func _process(delta):
	if parent_body:
		angle += orbit_speed * delta
		position = parent_body.position + Vector2(cos(angle), sin(angle)) * orbit_radius
