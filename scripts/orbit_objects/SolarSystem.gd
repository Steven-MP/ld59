extends Node2D

@export var planet_scene: PackedScene

@onready var sun = $Sun

const EARTH_TEXTURE = preload("res://assets/sprites/earth.png")
const PLANET_TEXTURES = [
	preload("res://assets/sprites/planet-1.png"),
	preload("res://assets/sprites/planet-2.png"),
	preload("res://assets/sprites/planet-3.png"),
]

var _planet_spawn_index := 0

func _ready():
	spawn_planets()

func spawn_planets():
	create_planet("Earth", 400, sun, 0.4)

func create_planet(name: String, orbit_radius: float, center: Node2D, speed: float):
	var planet = planet_scene.instantiate()
	planet.name = name
	add_child(planet)

	planet.orbit_radius = orbit_radius
	planet.orbit_center = center
	planet.orbit_speed = speed
	var final_scale = 0.25 * randf_range(0.8, 1.2)
	planet.scale = Vector2.ONE * final_scale * 0.1
	planet.create_tween().tween_property(planet, "scale", Vector2.ONE * final_scale, 0.5)
	planet.angle = randf() * TAU

	if center == null:
		planet.position = Vector2.ZERO

	_assign_texture(planet, name)

	return planet

func _assign_texture(planet: Node2D, planet_name: String):
	var sprite = planet.get_node("Sprite2D")
	if planet_name == "Earth":
		sprite.texture = EARTH_TEXTURE
	else:
		var texture: Texture2D
		if _planet_spawn_index < PLANET_TEXTURES.size():
			texture = PLANET_TEXTURES[_planet_spawn_index]
		else:
			texture = PLANET_TEXTURES[randi() % PLANET_TEXTURES.size()]
		sprite.texture = texture
		_planet_spawn_index += 1

var planet_queue = [
	{ "name": "Mars", "orbit_radius": 600, "speed": 0.3 },
	{ "name": "Jupiter", "orbit_radius": 300, "speed": 0.1 },
	{ "name": "Saturn", "orbit_radius": 900, "speed": 0.07 }
]

var unlocked_planets := []

func unlock_next_planet():
	if planet_queue.is_empty():
		return

	var data = planet_queue.pop_front()
	var planet = create_planet(data.name, data.orbit_radius, $Sun, data.speed)
	unlocked_planets.append(planet)
