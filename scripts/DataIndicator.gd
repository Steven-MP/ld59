extends Node2D

var source: Node2D

func _ready():
	top_level = true

func _process(_delta):
	if source == null:
		queue_free()
		return

	if not _is_data_source():
		return

	var pct = source.stored_data / source.max_storage
	if pct >= 1.0:
		GameState.game_over = true

	# Sit directly on the planet centre
	global_position = source.global_position
	queue_redraw()

func _is_data_source() -> bool:
	if not ("stored_data" in source and "max_storage" in source):
		return false
	if source.get("name") == "Earth":
		return false
	if "planet" in source and source.planet != null and source.planet.name == "Earth":
		return false
	return true

func _visual_radius() -> float:
	var sprite = source.get_node_or_null("Sprite2D")
	if sprite and sprite.texture:
		return sprite.texture.get_size().y * 0.5 * source.scale.y
	if "radius" in source:
		return source.radius * source.scale.y
	return 20.0

func _draw():
	if source == null or not _is_data_source():
		return

	var pct = clamp(source.stored_data / source.max_storage, 0.0, 1.0)

	var arc_color: Color
	if pct < 0.75:
		arc_color = Color.GREEN
	elif pct < 0.90:
		arc_color = Color.YELLOW
	else:
		arc_color = Color.RED

	var arc_r = _visual_radius()
	var arc_width = 3.0
	var point_count = 64

	# Dark background ring so the arc reads against any planet colour
	draw_arc(Vector2.ZERO, arc_r, 0, TAU, point_count,
			Color(0.0, 0.0, 0.0, 0.55), arc_width + 2.0)

	# Progress arc: starts at top (-PI/2), fills clockwise
	if pct > 0.0:
		draw_arc(Vector2.ZERO, arc_r, -PI / 2.0, -PI / 2.0 + TAU * pct,
				max(3, int(point_count * pct)), arc_color, arc_width)

	# Percentage text centred on the planet
	var font = ThemeDB.fallback_font
	var font_size = 18
	var text = "%d%%" % int(pct * 100)

	# Fix background to the widest possible string ("100%") so it never resizes
	var max_size = font.get_string_size("100%", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var bg_radius = max(max_size.x, max_size.y) * 0.75 * 0.8
	draw_circle(Vector2.ZERO, bg_radius, Color(0.0, 0.0, 0.0, 0.75))

	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var ascent = font.get_ascent(font_size)
	var text_pos = Vector2(-text_size.x / 2.0, ascent / 2.0)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, arc_color)
