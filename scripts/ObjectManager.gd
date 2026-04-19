extends Node2D

enum PlacementType { NONE, RADAR_WIDE, RADAR_STANDARD, SATELLITE_STANDARD, SATELLITE_TIGHT }

@export var radar_scene: PackedScene
@export var satellite_scene: PackedScene
@export var ghost_scene: PackedScene

@export var start_radar_wide := 2
@export var start_satellite_standard := 3

var inventory := {
	PlacementType.RADAR_WIDE: 0,
	PlacementType.RADAR_STANDARD: 0,
	PlacementType.SATELLITE_STANDARD: 0,
	PlacementType.SATELLITE_TIGHT: 0,
}

var current_type := PlacementType.NONE
var ghost: Node2D

func _ready():
	set_process_input(true)
	inventory[PlacementType.RADAR_WIDE] = start_radar_wide
	inventory[PlacementType.SATELLITE_STANDARD] = start_satellite_standard

func add_inventory(type: PlacementType, amount: int):
	inventory[type] += amount

func start_placement(type: PlacementType):
	if inventory[type] <= 0:
		return

	current_type = type

	if ghost:
		ghost.queue_free()

	ghost = ghost_scene.instantiate()
	ghost.placement_mode = "radar" if _is_radar_type(type) else "satellite"
	add_child(ghost)

func cancel_placement():
	current_type = PlacementType.NONE

	if ghost:
		ghost.queue_free()
		ghost = null

func _input(event):
	if current_type == PlacementType.NONE:
		return

	if event is InputEventMouseMotion:
		update_ghost_position()

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if ghost and ghost.is_valid:
				place_object()

		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			cancel_placement()

func _is_radar_type(type: PlacementType) -> bool:
	return type == PlacementType.RADAR_WIDE or type == PlacementType.RADAR_STANDARD

func update_ghost_position():
	var mouse_pos = get_global_mouse_position()
	var planet = get_nearest_planet(mouse_pos)
	if planet == null:
		return

	var dir = mouse_pos - planet.global_position

	if _is_radar_type(current_type):
		var snapped_dir = dir.normalized()
		ghost.global_position = planet.global_position + snapped_dir * planet.radius
		# Face outward from planet surface
		ghost.global_rotation = snapped_dir.angle()
	else:
		var dist = clamp(dir.length(), planet.radius + 20, planet.radius + 60)
		ghost.global_position = planet.global_position + dir.normalized() * dist
		ghost.orbit_center = planet.global_position
		ghost.orbit_radius = dist

	ghost.set_valid(validate_position(mouse_pos))

func validate_position(pos: Vector2) -> bool:
	if _is_radar_type(current_type):
		return validate_radar(pos)
	else:
		return validate_satellite(pos)

func validate_radar(pos: Vector2) -> bool:
	return get_nearest_planet(pos) != null

func validate_satellite(pos: Vector2) -> bool:
	var planet = get_nearest_planet(pos)
	if planet == null:
		return false
	var dist = pos.distance_to(planet.global_position)
	return dist > planet.radius + 20 and dist < planet.radius + 60

func place_object():
	var mouse_pos = get_global_mouse_position()

	if inventory[current_type] <= 0:
		cancel_placement()
		return

	if _is_radar_type(current_type):
		place_radar_at(mouse_pos, current_type)
	else:
		place_satellite_at(mouse_pos, current_type)

	inventory[current_type] -= 1
	cancel_placement()

func place_radar_at(pos: Vector2, type: PlacementType):
	var planet = get_nearest_planet(pos)
	if planet == null:
		return

	var dir = (pos - planet.global_position).normalized()

	var radar = radar_scene.instantiate()
	add_child(radar)

	radar.planet = planet
	radar.surface_angle = dir.angle() - planet.rotation
	radar.current_band = 0 if type == PlacementType.RADAR_WIDE else 1
	radar.scale = Vector2(0.2, 0.2)

func place_satellite_at(pos: Vector2, type: PlacementType):
	var planet = get_nearest_planet(pos)
	if planet == null:
		return

	var dir = pos - planet.global_position

	var satellite = satellite_scene.instantiate()
	add_child(satellite)

	satellite.planet = planet
	satellite.orbit_radius = dir.length()
	satellite.angle = dir.angle()
	satellite.current_band = 1 if type == PlacementType.SATELLITE_STANDARD else 2
	satellite.scale = Vector2(0.2, 0.2)

func get_nearest_planet(pos: Vector2):
	var planets = get_tree().get_nodes_in_group("planets")
	var closest = null
	var closest_dist = INF

	for planet in planets:
		var d = pos.distance_to(planet.global_position)
		if d < closest_dist:
			closest = planet
			closest_dist = d

	return closest

func get_planet_surface_angle(planet: Node2D, world_pos: Vector2) -> float:
	return (world_pos - planet.global_position).angle()
