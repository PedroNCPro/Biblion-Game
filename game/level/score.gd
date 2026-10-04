extends Control

func _ready() -> void:
	reset()

func reset() -> void:
	$AnimatedChar.set_char("0")

func update_points(pts : int) -> void:
	$AnimatedChar.activate(0.0)
	$AnimatedChar.set_char(str(pts))
