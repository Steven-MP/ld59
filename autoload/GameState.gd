extends Node

var score := 0.0
var game_over := false
var upgrade_pending := false
var upgrade_count := 0

func reset():
	score = 0.0
	game_over = false
	upgrade_pending = false
	upgrade_count = 0
