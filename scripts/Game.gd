extends Node

@onready var solar_system = $SolarSystem
@onready var connection_manager = $ConnectionManager
@onready var camera = $Camera2D

var year_length := 60.0
var year_timer := 0.0
var unlock_time := 10.0
var unlock_triggered := false

# base_zoom = the highest zoom value that still fits all planets on screen.
# Lower zoom = more zoomed out = sees more world.
var base_zoom := 1.0
var user_zoom := 1.0
var manually_zoomed := false
var camera_target_pos := Vector2.ZERO

const MAX_ORBIT_OFFSET := 120.0  # must match ObjectManager validate_satellite
const ZOOM_STEP := 1.3
const ZOOM_LERP_SPEED := 4.0
const PAN_LERP_SPEED := 4.0

func _process(delta):
	year_timer += delta
	GameState.year_timer = year_timer

	if year_timer >= unlock_time and not unlock_triggered:
		unlock_triggered = true
		solar_system.unlock_next_planet()

	if year_timer >= year_length:
		year_timer = 0
		unlock_triggered = false
		pause_for_upgrade()

	_update_base_zoom()

	# When a new planet spawns, base_zoom decreases — force zoom out regardless
	# of manual state so the new planet is always visible on spawn.
	if user_zoom > base_zoom:
		user_zoom = base_zoom
		manually_zoomed = false
		camera_target_pos = Vector2.ZERO
	elif not manually_zoomed:
		user_zoom = base_zoom

	camera.zoom = camera.zoom.lerp(Vector2(user_zoom, user_zoom), delta * ZOOM_LERP_SPEED)
	camera.position = camera.position.lerp(camera_target_pos, delta * PAN_LERP_SPEED)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()

func _zoom_in():
	var nearest = _get_nearest_planet(camera.get_global_mouse_position())
	var max_close_zoom := 3.0

	if nearest:
		var vp = get_viewport().get_visible_rect().size
		var extent = nearest.radius + MAX_ORBIT_OFFSET + 20.0
		max_close_zoom = min(vp.x, vp.y) / (2.0 * extent)
		camera_target_pos = nearest.global_position

	var new_zoom = min(user_zoom * ZOOM_STEP, max_close_zoom)
	if new_zoom > user_zoom:
		manually_zoomed = true
		user_zoom = new_zoom

func _zoom_out():
	manually_zoomed = false
	user_zoom = base_zoom
	camera_target_pos = Vector2.ZERO

func _update_base_zoom():
	var planets = get_tree().get_nodes_in_group("planets")
	var vp = get_viewport().get_visible_rect().size
	var padding := 0.85
	var min_z := base_zoom  # start from current — never increase automatically

	for planet in planets:
		if not ("orbit_radius" in planet):
			continue  # skip nodes without an orbit (e.g. Sun)
		var r = planet.orbit_radius
		if r < 10.0:
			continue
		# Worst-case position is directly above/below or left/right of centre,
		# so check both axes independently against the orbit radius.
		min_z = min(min_z, vp.x * 0.5 / r * padding)
		min_z = min(min_z, vp.y * 0.5 / r * padding)

	base_zoom = clamp(min_z, 0.1, 1.5)

func pause_for_upgrade():
	GameState.upgrade_count += 1
	GameState.upgrade_pending = true
	get_tree().paused = true

func _get_nearest_planet(pos: Vector2) -> Node2D:
	var planets = get_tree().get_nodes_in_group("planets")
	var nearest: Node2D = null
	var nearest_dist := INF
	for planet in planets:
		var d = pos.distance_to(planet.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = planet
	return nearest
