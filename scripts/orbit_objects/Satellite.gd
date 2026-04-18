extends "res://scripts/orbit_objects/OrbitObject.gd"

enum OrbitType { NORMAL, GEO_SYNC }
enum BandType { WIDE, STANDARD, TIGHT }

@export var current_band: BandType = BandType.STANDARD
@export var max_connections := 2

@export var orbit_type: OrbitType = OrbitType.NORMAL
@export var planet: Node2D

var stored_data := 0.0
@export var max_storage := 50.0
@export var data_rate := 3.0

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
			orbit_speed = planet.rotation_speed

	if planet.name != "Earth":
		stored_data += data_rate * delta

	stored_data = min(stored_data, max_storage)

	super._process(delta)

func _ready():
	add_to_group("connectable")
	var indicator = load("res://scripts/DataIndicator.gd").new()
	indicator.source = self
	add_child(indicator)
