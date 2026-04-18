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

	var offset_y = -25.0
	if "radius" in source:
		offset_y = -(source.radius + 25.0)

	global_position = source.global_position + Vector2(0, offset_y)
	queue_redraw()

func _is_data_source() -> bool:
	if not ("stored_data" in source and "max_storage" in source):
		return false
	if source.get("name") == "Earth":
		return false
	if "planet" in source and source.planet != null and source.planet.name == "Earth":
		return false
	return true

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

	var arc_r = 14.0
	var arc_width = 3.0
	var point_count = 48

	# Background ring
	draw_arc(Vector2.ZERO, arc_r, 0, TAU, point_count, Color(0.15, 0.15, 0.15, 0.75), arc_width)

	# Progress arc: starts at top (-PI/2), fills clockwise
	if pct > 0.0:
		draw_arc(Vector2.ZERO, arc_r, -PI / 2.0, -PI / 2.0 + TAU * pct,
				max(3, int(point_count * pct)), arc_color, arc_width)

	# Percentage text centred inside the ring
	var font = ThemeDB.fallback_font
	var font_size = 7
	var text = "%d%%" % int(pct * 100)
	var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var ascent = font.get_ascent(font_size)
	draw_string(font, Vector2(-text_width / 2.0, ascent / 2.0),
			text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, arc_color)
