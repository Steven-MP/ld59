extends CanvasLayer

@onready var object_manager = $"../ObjectManager"

func _process(delta):
	if GameState.game_over:
		print("GAME OVER")

func _on_place_radar_pressed():
	print("Button pressed")
	object_manager.start_placement(object_manager.PlacementType.RADAR)

func _on_place_satellite_pressed():
	print("Button 2 pressed")
	object_manager.start_placement(object_manager.PlacementType.SATELLITE)
