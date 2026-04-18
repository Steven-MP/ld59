extends Node2D

@export var planet: Node2D
enum BandType { WIDE, STANDARD, TIGHT }

@export var current_band: BandType = BandType.STANDARD
@export var max_connections := 2

# angle ON the planet surface (local attachment point)
var surface_angle := 0.0

@export var radius_offset := 0.0

var stored_data := 0.0
@export var max_storage := 50.0
@export var data_rate := 3.0

func _process(delta):
	if planet == null:
		return

	var planet_radius = planet.radius

	var effective_angle = surface_angle + planet.rotation
	var direction = Vector2(cos(effective_angle), sin(effective_angle))

	global_position = planet.global_position + direction * (planet_radius + radius_offset)
	global_rotation = direction.angle()

	if planet.name != "Earth":
		stored_data += data_rate * delta

	stored_data = min(stored_data, max_storage)

func _ready():
	add_to_group("connectable")
