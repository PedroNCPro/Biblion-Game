extends Node2D
class_name LevelGenerator


@export var level_template_scene: PackedScene = preload("res://game/level/level_template.tscn")
@export var grid_scene: PackedScene
@export var keyboard_scene: PackedScene
@export var background_scene: PackedScene
@export_group("Grid generation parameters")
@export var min_word_size: int
@export var max_word_size: int
@export var attempts: int
@export_group("Level parameters")
@export var point_threshold: int
@export var current_level: int


## This function builds a [Level] from [Grid], [Keyboard], and [Background] resources.
## It returns the root node of the generated [Level] scene.
func generate_level(grid_resource: GridResource = null, keyboard_resource: Resource = null, background_resource: Resource = null):
	var level_template_node = level_template_scene.instantiate()
	var grid_node = grid_scene.instantiate()
	var keyboard_node = keyboard_scene.instantiate()
	var background_node = background_scene.instantiate()

	if not grid_resource: 
		grid_resource = GridEditor.generate_random_grid(min_word_size, max_word_size, attempts)
	grid_node.setup(grid_resource)
	#keyboard_node.setup(keyboard_resource)
	#background_node.setup(background_resource)
	level_template_node.grid = grid_node
	level_template_node.keyboard = keyboard_node
	level_template_node.background = background_node
	level_template_node.point_threshold = point_threshold
	level_template_node.level_label.text = "Level " + str(current_level)
	level_template_node.setup()

	return level_template_node
