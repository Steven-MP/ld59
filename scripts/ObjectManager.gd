extends Node2D

enum PlacementType { NONE, RADAR, SATELLITE }

@export var radar_scene: PackedScene
@export var satellite_scene: PackedScene
@export var ghost_scene: PackedScene

var current_type := PlacementType.NONE
var ghost: Node2D
	
func _ready():
	set_process_input(true)

func start_placement(type: PlacementType):
	current_type = type
	
	if ghost:
		ghost.queue_free()
	
	ghost = ghost_scene.instantiate()
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

func update_ghost_position():
	var mouse_pos = get_global_mouse_position()
	var planet = get_nearest_planet(mouse_pos)
	if planet == null:
		return

	var angle = get_planet_surface_angle(planet, mouse_pos)
	var radius = planet.radius
	ghost.global_position = planet.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	var dir = mouse_pos - planet.global_position
	
	match current_type:
		PlacementType.RADAR:
			var snapped = planet.global_position + dir.normalized() * planet.radius
			ghost.global_position = snapped
		
		PlacementType.SATELLITE:
			var dist = clamp(dir.length(), planet.radius + 20, planet.radius + 120)
			ghost.global_position = planet.global_position + dir.normalized() * dist
	
	var valid = validate_position(mouse_pos)
	ghost.set_valid(valid)

func validate_position(pos: Vector2) -> bool:
	match current_type:
		PlacementType.RADAR:
			return validate_radar(pos)
		PlacementType.SATELLITE:
			return validate_satellite(pos)
	
	return false
	
func validate_radar(pos: Vector2) -> bool:
	var planet = get_nearest_planet(pos)
	if planet == null:
		return false
	
	var dist = pos.distance_to(planet.global_position)
	return abs(dist - planet.radius) < 10
	
func validate_satellite(pos: Vector2) -> bool:
	var planet = get_nearest_planet(pos)
	if planet == null:
		return false
	
	var dist = pos.distance_to(planet.global_position)
	
	var min_orbit = planet.radius + 20
	var max_orbit = planet.radius + 120
	
	return dist > min_orbit and dist < max_orbit
	
func place_object():
	var mouse_pos = get_global_mouse_position()
	
	match current_type:
		PlacementType.RADAR:
			place_radar_at(mouse_pos)
		PlacementType.SATELLITE:
			place_satellite_at(mouse_pos)
	
	cancel_placement()
	
func place_radar_at(pos: Vector2):
	var planet = get_nearest_planet(pos)
	if planet == null:
		return
	
	var dir = (pos - planet.global_position).normalized()
	var angle = dir.angle()
	
	var radar = radar_scene.instantiate()
	add_child(radar)
	
	radar.planet = planet
	radar.surface_angle = angle
	
func place_satellite_at(pos: Vector2):
	var planet = get_nearest_planet(pos)
	if planet == null:
		return
	
	var dir = pos - planet.global_position
	var dist = dir.length()
	
	var satellite = satellite_scene.instantiate()
	add_child(satellite)
	
	satellite.planet = planet
	satellite.orbit_radius = dist
	satellite.angle = dir.angle()
	
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
	var dir = world_pos - planet.global_position
	return dir.angle()
