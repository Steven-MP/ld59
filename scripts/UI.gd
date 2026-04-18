extends CanvasLayer

const OM = preload("res://scripts/ObjectManager.gd")

@export var upgrade_radar_amount := 2
@export var upgrade_satellite_amount := 3

@onready var object_manager = $"../ObjectManager"
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var btn_wide_radar = $VBoxContainer/BtnWideRadar
@onready var btn_standard_radar = $VBoxContainer/BtnStandardRadar
@onready var btn_standard_sat = $VBoxContainer/BtnStandardSat
@onready var btn_tight_sat = $VBoxContainer/BtnTightSat
@onready var game_over_screen = $GameOverScreen
@onready var final_score_label = $GameOverScreen/VBox/FinalScore
@onready var upgrade_screen = $UpgradeScreen
@onready var option_a_btn = $UpgradeScreen/VBox/OptionA
@onready var option_b_btn = $UpgradeScreen/VBox/OptionB

# Upgrade options per year. Each entry is [option_a, option_b] where each
# option is { label, type, amount }. Amounts are filled in _ready().
var upgrade_options: Array = []
var _pending_options: Array = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	upgrade_options = [
		# Year 1: radar vs satellite
		[
			{ "type": OM.PlacementType.RADAR_WIDE },
			{ "type": OM.PlacementType.SATELLITE_STANDARD },
		],
		# Year 2: wide vs standard radar
		[
			{ "type": OM.PlacementType.RADAR_WIDE },
			{ "type": OM.PlacementType.RADAR_STANDARD },
		],
		# Year 3+: standard vs tight satellite
		[
			{ "type": OM.PlacementType.SATELLITE_STANDARD },
			{ "type": OM.PlacementType.SATELLITE_TIGHT },
		],
	]

func _type_label(type: OM.PlacementType, amount: int) -> String:
	match type:
		OM.PlacementType.RADAR_WIDE:     return "%d Wide Radar%s" % [amount, "s" if amount != 1 else ""]
		OM.PlacementType.RADAR_STANDARD: return "%d Std Radar%s" % [amount, "s" if amount != 1 else ""]
		OM.PlacementType.SATELLITE_STANDARD: return "%d Std Satellite%s" % [amount, "s" if amount != 1 else ""]
		OM.PlacementType.SATELLITE_TIGHT:    return "%d Tight Satellite%s" % [amount, "s" if amount != 1 else ""]
	return ""

func _amount_for_type(type: OM.PlacementType) -> int:
	match type:
		OM.PlacementType.RADAR_WIDE, OM.PlacementType.RADAR_STANDARD:
			return upgrade_radar_amount
		_:
			return upgrade_satellite_amount

func _process(_delta):
	# Score
	score_label.text = "Downloaded: %.0f GB" % GameState.score

	# Placement button labels + disabled state
	var inv = object_manager.inventory
	btn_wide_radar.text    = "Wide Radar (%d)" % inv[OM.PlacementType.RADAR_WIDE]
	btn_standard_radar.text = "Std Radar (%d)" % inv[OM.PlacementType.RADAR_STANDARD]
	btn_standard_sat.text  = "Std Satellite (%d)" % inv[OM.PlacementType.SATELLITE_STANDARD]
	btn_tight_sat.text     = "Tight Satellite (%d)" % inv[OM.PlacementType.SATELLITE_TIGHT]

	btn_wide_radar.disabled    = inv[OM.PlacementType.RADAR_WIDE] <= 0
	btn_standard_radar.disabled = inv[OM.PlacementType.RADAR_STANDARD] <= 0
	btn_standard_sat.disabled  = inv[OM.PlacementType.SATELLITE_STANDARD] <= 0
	btn_tight_sat.disabled     = inv[OM.PlacementType.SATELLITE_TIGHT] <= 0

	# Game over
	if GameState.game_over and not game_over_screen.visible:
		game_over_screen.visible = true
		final_score_label.text = "Final Score: %.0f GB" % GameState.score
		get_tree().paused = true

	# Upgrade screen
	if GameState.upgrade_pending and not upgrade_screen.visible:
		_show_upgrade_screen()

func _show_upgrade_screen():
	var idx = clamp(GameState.upgrade_count - 1, 0, upgrade_options.size() - 1)
	_pending_options = upgrade_options[idx]

	var a = _pending_options[0]
	var b = _pending_options[1]
	option_a_btn.text = _type_label(a.type, _amount_for_type(a.type))
	option_b_btn.text = _type_label(b.type, _amount_for_type(b.type))

	upgrade_screen.visible = true

func _apply_upgrade(option: Dictionary):
	var amount = _amount_for_type(option.type)
	object_manager.add_inventory(option.type, amount)
	upgrade_screen.visible = false
	GameState.upgrade_pending = false
	get_tree().paused = false

func _on_option_a_pressed():
	if _pending_options.is_empty():
		return
	_apply_upgrade(_pending_options[0])

func _on_option_b_pressed():
	if _pending_options.is_empty():
		return
	_apply_upgrade(_pending_options[1])

func _on_btn_wide_radar_pressed():
	object_manager.start_placement(OM.PlacementType.RADAR_WIDE)

func _on_btn_standard_radar_pressed():
	object_manager.start_placement(OM.PlacementType.RADAR_STANDARD)

func _on_btn_standard_sat_pressed():
	object_manager.start_placement(OM.PlacementType.SATELLITE_STANDARD)

func _on_btn_tight_sat_pressed():
	object_manager.start_placement(OM.PlacementType.SATELLITE_TIGHT)
