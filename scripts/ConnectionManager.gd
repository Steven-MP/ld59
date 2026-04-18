extends Node2D

enum BandType { WIDE, STANDARD, TIGHT }

var band_settings = {
	BandType.WIDE: { "angle": 90.0, "range": 200.0, "color": Color.GREEN, "bandwidth": 10.0 },
	BandType.STANDARD: { "angle": 30.0, "range": 400.0, "color": Color.YELLOW, "bandwidth": 20.0 },
	BandType.TIGHT: { "angle": 10.0, "range": 800.0, "color": Color.RED, "bandwidth": 40.0 }
}

var connections := {} 
# key: "a_id_b_id" → {a, b, band, stable_time}
	
	
func _process(delta):
	update_connections(delta)
	collect_planet_data(delta)
	transfer_data(delta)
	queue_redraw()

func is_valid_connection(a, b) -> bool:
	if a == null or b == null:
		return false
		
	# Line of sight check
	if is_line_blocked(a, b):
		return false
	
	# 🔒 Ensure property exists
	if not ("current_band" in a):
		return false
	
	if not band_settings.has(a.current_band):
		return false
	
	var settings = band_settings[a.current_band]

	var distance = a.global_position.distance_to(b.global_position)
	if distance > settings.range:
		return false

	# Receiver angle check: radars are directional (they have surface_angle).
	# Satellites and planets are omnidirectional receivers.
	if "surface_angle" in b and "current_band" in b and band_settings.has(b.current_band):
		var b_settings = band_settings[b.current_band]
		var dir_to_sender = (a.global_position - b.global_position).normalized()
		var b_forward = b.global_transform.x
		var recv_angle = rad_to_deg(acos(clamp(b_forward.dot(dir_to_sender), -1.0, 1.0)))
		if recv_angle > b_settings.angle:
			return false

	return true

func _draw():
	for c in connections.values():
		if c.stable_time < 0.2:
			continue
		
		var settings = band_settings[c.band]
		
		draw_line(
			c.a.global_position,
			c.b.global_position,
			settings.color,
			2
		)
		
func update_connections(delta):
	var new_connections := {}
	var nodes = get_tree().get_nodes_in_group("connectable")
	
	for a in nodes:
		if not ("max_connections" in a):
			continue
		
		var candidates := []
		
		for b in nodes:
			if a == b:
				continue
			
			if is_valid_connection(a, b):
				var dist = a.global_position.distance_to(b.global_position)
				candidates.append({ "node": b, "distance": dist })
		
		candidates.sort_custom(func(x, y): return x.distance < y.distance)
		
		for i in range(min(a.max_connections, candidates.size())):
			var b = candidates[i].node
			var key = str(a.get_instance_id()) + "_" + str(b.get_instance_id())
			
			if connections.has(key):
				new_connections[key] = connections[key]
				new_connections[key].stable_time += delta
			else:
				new_connections[key] = {
					"a": a,
					"b": b,
					"band": a.current_band,
					"stable_time": 0.0
				}
	
	connections = new_connections

			
func is_line_blocked(a: Node2D, b: Node2D) -> bool:
	var planets = get_tree().get_nodes_in_group("planets")
	
	for planet in planets:
		# Ignore if one of the endpoints is on this planet
		if a == planet or b == planet:
			continue
		
		var center = planet.global_position
		var radius = planet.radius
		
		# Line segment: A → B
		var p1 = a.global_position
		var p2 = b.global_position
		
		# Project center onto line
		var line_dir = (p2 - p1).normalized()
		var to_center = center - p1
		
		var projection = to_center.dot(line_dir)
		
		# Clamp to segment
		projection = clamp(projection, 0, p1.distance_to(p2))
		
		var closest_point = p1 + line_dir * projection
		
		var dist_to_center = center.distance_to(closest_point)
		
		if dist_to_center < radius * 0.95:
			return true  #blocked!
	
	return false
	
func collect_planet_data(delta):
	var collection_rate := 15.0
	for node in get_tree().get_nodes_in_group("connectable"):
		if not ("planet" in node):
			continue
		var planet = node.planet
		if planet == null or not ("stored_data" in planet) or planet.stored_data <= 0:
			continue
		if not ("stored_data" in node) or node.stored_data >= node.max_storage:
			continue
		var transfer = min(collection_rate * delta, planet.stored_data, node.max_storage - node.stored_data)
		planet.stored_data -= transfer
		node.stored_data += transfer

func transfer_data(delta):
	for c in connections.values():
		if c.stable_time < 0.2:
			continue

		var a = c.a
		var b = c.b

		if not ("stored_data" in a) or a.stored_data <= 0:
			continue

		var settings = band_settings[c.band]
		var transfer = min(settings.bandwidth * delta, a.stored_data)

		# Earth is the sink — score the data
		if b.is_in_group("earth"):
			a.stored_data -= transfer
			GameState.score += transfer
		elif "stored_data" in b:
			# Gradient flow: only push data toward nodes with less
			if a.stored_data > b.stored_data:
				a.stored_data -= transfer
				b.stored_data = min(b.stored_data + transfer, b.max_storage)
