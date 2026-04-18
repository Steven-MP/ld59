extends Node2D
@export var orbit_radius := 0.0
@export var orbit_speed := 0.1
@export var orbit_center: Node2D
@export var rotation_speed := 0.5
@export var radius := 50.0

@export var data_rate := 5.0
@export var max_storage := 100.0
var stored_data := 0.0

var angle := 0.0

func _process(delta):
	if orbit_center:
		angle += orbit_speed * delta
		position = orbit_center.position + Vector2(cos(angle), sin(angle)) * orbit_radius

	rotation += rotation_speed * delta

	if name != "Earth":
		stored_data = min(stored_data + data_rate * delta, max_storage)

func _ready():
	add_to_group("planets")

	if name == "Earth":
		add_to_group("earth")
		add_to_group("connectable")
	else:
		_add_indicator()

func _add_indicator():
	var indicator = load("res://scripts/DataIndicator.gd").new()
	indicator.source = self
	add_child(indicator)
