extends CanvasLayer

@onready var object_manager = $"../ObjectManager"
@onready var score_label = $VBoxContainer/ScoreLabel

func _process(delta):
	score_label.text = "Downloaded: %.0f GB" % GameState.score

func _on_place_radar_pressed():
	object_manager.start_placement(object_manager.PlacementType.RADAR)

func _on_place_satellite_pressed():
	object_manager.start_placement(object_manager.PlacementType.SATELLITE)
