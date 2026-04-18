extends Node2D

enum BandType { WIDE, STANDARD, TIGHT }

var band_settings = {
	BandType.WIDE: { "angle": 90.0, "range": 200.0, "color": Color.GREEN },
	BandType.STANDARD: { "angle": 30.0, "range": 400.0, "color": Color.YELLOW },
	BandType.TIGHT: { "angle": 10.0, "range": 800.0, "color": Color.RED }
}

var connections := []

func _process(delta):
	if GameState.game_over:
		return
	
	connections.clear()
	
	var nodes = get_tree().get_nodes_in_group("connectable")
	
	for a in nodes:
		for b in nodes:
			if a == b:
				continue
			
			if can_connect(a, b):
				connections.append([a, b])
	
	queue_redraw()

func can_connect(a, b):
	var dir = (b.global_position - a.global_position)
	var distance = dir.length()
	
	var settings = band_settings[a.current_band]
	
	if distance > settings["range"]:
		return false
	
	var forward = a.transform.x
	var angle = rad_to_deg(acos(forward.dot(dir.normalized())))
	
	return angle <= settings["angle"]

func _draw():
	for c in connections:
		var a = c[0]
		var b = c[1]
		draw_line(a.position, b.position, Color.WHITE, 2)
