extends Control

const MONTHS := 12
const CIRCLE_RADIUS := 10.0
const SPACING := 28.0
const LINE_WIDTH := 2.0
const COLOR := Color(0.85, 0.95, 1.0, 1.0)

func _process(_delta):
	queue_redraw()

func _draw():
	var months_elapsed = clamp(
		int(GameState.year_timer / (GameState.year_length / MONTHS)),
		0, MONTHS
	)

	for i in range(MONTHS):
		var center = Vector2(CIRCLE_RADIUS + i * SPACING, size.y * 0.5)

		if i < months_elapsed:
			draw_circle(center, CIRCLE_RADIUS, COLOR)
		else:
			# Outline only
			draw_arc(center, CIRCLE_RADIUS, 0.0, TAU, 32, COLOR, LINE_WIDTH)
