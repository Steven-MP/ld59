extends CanvasLayer

@onready var object_manager = $"../ObjectManager"
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var game_over_screen = $GameOverScreen
@onready var final_score_label = $GameOverScreen/VBox/FinalScore

func _process(_delta):
	score_label.text = "Downloaded: %.0f GB" % GameState.score

	if GameState.game_over and not game_over_screen.visible:
		game_over_screen.visible = true
		final_score_label.text = "Final Score: %.0f GB" % GameState.score
		get_tree().paused = true

func _on_place_radar_pressed():
	object_manager.start_placement(object_manager.PlacementType.RADAR)

func _on_place_satellite_pressed():
	object_manager.start_placement(object_manager.PlacementType.SATELLITE)
