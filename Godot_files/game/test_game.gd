extends Node2D

@export var level_resource: LevelResource


func _ready() -> void:
	var level = LevelGenerator.create_level_from_resource(level_resource)
	add_child(level)
