extends "res://scripts/orbit_objects/OrbitObject.gd"

enum OrbitType { NORMAL, GEO_SYNC }

@export var orbit_type: OrbitType = OrbitType.NORMAL
@export var planet: Node2D

func _process(delta):
	if planet == null:
		return
	
	angle += orbit_speed * delta
	
	var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
	global_position = planet.global_position + offset
	
	match orbit_type:
		OrbitType.NORMAL:
			orbit_speed = 1.2
		OrbitType.GEO_SYNC:
			orbit_speed = parent_body.rotation_speed
	
	super._process(delta)
