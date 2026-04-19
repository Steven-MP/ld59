extends Node

const FONT = preload("res://assets/Astrolab.ttf")

func _ready():
	ThemeDB.fallback_font = FONT

var score := 0.0
var game_over := false
var upgrade_pending := false
var upgrade_count := 0
var year_timer := 0.0
var year_length := 60.0

func reset():
	score = 0.0
	game_over = false
	upgrade_pending = false
	upgrade_count = 0
	year_timer = 0.0
