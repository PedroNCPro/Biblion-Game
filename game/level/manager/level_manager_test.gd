extends Node


@export var grid: GridResource
@export var keyboard: Resource
@export var background: Resource
@export var generator: LevelGenerator


func _ready() -> void:
	add_child(generator.generate_level(grid, keyboard, background))
