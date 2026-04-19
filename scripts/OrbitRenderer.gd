extends Node2D

const COLOR := Color(1.0, 1.0, 1.0, 0.15)
const LINE_WIDTH := 3.0
const BASE_DASH_COUNT := 60   # dash count at BASE_RADIUS
const BASE_RADIUS := 200.0    # reference orbit (Earth) — scale relative to this
const DASH_FRACTION := 0.45

func _process(_delta):
	queue_redraw()

func _draw():
	for planet in get_tree().get_nodes_in_group("planets"):
		if not ("orbit_radius" in planet):
			continue
		var r = planet.orbit_radius
		if r < 1.0 or planet.orbit_center == null:
			continue

		var center = planet.orbit_center.global_position

		# Angle the planet is currently at, and how wide a gap to leave
		var planet_angle = (planet.global_position - center).angle()
		var visual_radius = planet.radius * planet.scale.x
		# Add a small padding factor so the gap is slightly wider than the sprite
		var gap_half = asin(clamp(visual_radius / r, 0.0, 1.0)) * 1.3

		var dash_count = max(BASE_DASH_COUNT, int(BASE_DASH_COUNT * r / BASE_RADIUS))
		_draw_dotted_circle(center, r, planet_angle, gap_half, dash_count)

func _draw_dotted_circle(center: Vector2, radius: float, gap_angle: float, gap_half: float, dash_count: int):
	for i in range(dash_count):
		var start_angle = (float(i) / dash_count) * TAU
		var end_angle = start_angle + (DASH_FRACTION / dash_count) * TAU
		var mid_angle = (start_angle + end_angle) * 0.5

		# Wrap the difference into [-PI, PI] and skip if inside the planet gap
		var diff = fmod(mid_angle - gap_angle + PI, TAU) - PI
		if abs(diff) < gap_half:
			continue

		draw_arc(center, radius, start_angle, end_angle, 3, COLOR, LINE_WIDTH)
