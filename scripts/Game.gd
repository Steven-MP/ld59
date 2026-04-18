extends Node

@onready var solar_system = $SolarSystem
@onready var connection_manager = $ConnectionManager
@onready var camera = $Camera2D

var target_zoom := Vector2.ONE
var year_length := 60.0
var year_timer := 0.0
var unlock_time := 10.0  # 10 seconds before year end
var unlock_triggered := false

func _process(delta):
	year_timer += delta
	
	if year_timer >= unlock_time and not unlock_triggered:
		unlock_triggered = true
		solar_system.unlock_next_planet()
		update_camera_zoom()
	
	if year_timer >= year_length:
		year_timer = 0
		unlock_triggered = false
		pause_for_upgrade()
		
	update_camera_zoom()
	camera.zoom = camera.zoom.lerp(target_zoom, delta * 2.0)

func pause_for_upgrade():
	get_tree().paused = true
	print("Upgrade time!")
	
func update_camera_zoom():
	var planets = get_tree().get_nodes_in_group("planets")
	
	var max_distance := 100.0
	
	for planet in planets:
		var dist = planet.global_position.length()
		if dist > max_distance:
			max_distance = dist
	
	# 🔧 tweak divisor for feel
	var zoom_value = clamp(600.0 / max_distance, 0.3, 1.5)
	
	target_zoom = Vector2(zoom_value, zoom_value)
