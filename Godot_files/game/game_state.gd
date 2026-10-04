extends Node


signal points_changed
signal level_changed(lvl : int)
signal coins_changed(coins : int)

@export_group("Level")
@export var level: int = 1:
	set(v):
		level = v
		level_changed.emit(level)
@export var points: int = 0:
	set(value):
		points = value
		points_changed.emit(points)
@export var mystery_word: String = ""
@export var current_string_guess : String = ""
@export var current_attempt : int = 0
@export_group("Player")
@export var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)
@export var power_ups: Array[PowerUp] = []

var highest_score = 0
