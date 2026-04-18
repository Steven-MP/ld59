extends Node2D

@export var planet_scene: PackedScene

@onready var sun = $Sun

func _ready():
	spawn_planets()

func spawn_planets():
	create_planet("Earth", 200, sun, 0.4)

func create_planet(name: String, orbit_radius: float, center: Node2D, speed: float):
	var planet = planet_scene.instantiate()
	add_child(planet)
	
	planet.name = name
	planet.orbit_radius = orbit_radius
	planet.orbit_center = center
	planet.orbit_speed = speed
	planet.scale = Vector2.ONE * randf_range(0.5, 1.0)
	planet.create_tween().tween_property(planet, "scale", Vector2.ONE, 0.5)
	
	# Start at a random angle so they’re not aligned
	planet.angle = randf() * TAU
	
	# If no orbit center → it's the center planet (Earth in your case)
	if center == null:
		planet.position = Vector2.ZERO
		
var planet_queue = [
	{ "name": "Mars", "orbit_radius": 200, "speed": 0.2 },
	{ "name": "Jupiter", "orbit_radius": 350, "speed": 0.1 },
	{ "name": "Saturn", "orbit_radius": 500, "speed": 0.07 }
]

var unlocked_planets := []

func unlock_next_planet():
	if planet_queue.is_empty():
		return
	
	var data = planet_queue.pop_front()
	
	var planet = create_planet(
		data.name,
		data.orbit_radius,
		$Sun,
		data.speed
	)
	
	unlocked_planets.append(planet)
