extends Node2D

@export var planet: Node2D

# angle ON the planet surface (local attachment point)
var surface_angle := 0.0

@export var radius_offset := 0.0

func _process(delta):
	if planet == null:
		return
	
	var planet_radius = planet.radius
	
	# 🔥 KEY FIX: attach angle to planet rotation
	var effective_angle = surface_angle + planet.rotation
	
	var direction = Vector2(cos(effective_angle), sin(effective_angle))
	
	# Position follows rotating surface
	global_position = planet.global_position + direction * (planet_radius + radius_offset)
	
	# Always face outward from planet center
	global_rotation = direction.angle()
