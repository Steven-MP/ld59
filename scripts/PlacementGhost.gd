extends Node2D

@export var valid_color   := Color(0.2, 1.0, 0.4, 0.9)
@export var invalid_color := Color(1.0, 0.2, 0.2, 0.9)

const DOT_RADIUS      := 5.0
const ORBIT_DASH_FRAC := 0.45
const ORBIT_BASE_DASHES := 60

var is_valid := false

# Set by ObjectManager each frame
var placement_mode := "radar"   # "radar" or "satellite"
var orbit_center   := Vector2.ZERO
var orbit_radius   := 0.0

func set_valid(valid: bool):
	is_valid = valid

func _ready():
	# Hide the legacy Sprite2D — we draw everything ourselves
	var spr = get_node_or_null("Sprite2D")
	if spr:
		spr.visible = false

func _process(_delta):
	queue_redraw()

func _draw():
	var color = valid_color if is_valid else invalid_color

	# Small pulsing indicator dot at the cursor-snapped position
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.006) * 0.15
	draw_circle(Vector2.ZERO, DOT_RADIUS * pulse, color)

	if placement_mode == "satellite" and orbit_radius > 1.0:
		# Dotted circle showing the full orbit preview
		var local_center = to_local(orbit_center)
		_draw_dotted_orbit(local_center, orbit_radius, color)

func _draw_dotted_orbit(center: Vector2, radius: float, color: Color):
	var dash_count = max(ORBIT_BASE_DASHES, int(ORBIT_BASE_DASHES * radius / 200.0))
	for i in range(dash_count):
		var start_a = (float(i) / dash_count) * TAU
		var end_a   = start_a + (ORBIT_DASH_FRAC / dash_count) * TAU
		draw_arc(center, radius, start_a, end_a, 3, color, 1.5)
