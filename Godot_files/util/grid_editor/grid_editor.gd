@tool
extends Node
class_name GridEditor


@export_category("Grid Parameters")
@export_range(1, 100) var grid_size_x: int = 5:
	set(value):
		grid_size_x = value
		grid_resource.grid_size.x = value
		_update_grid_container()
@export_range(1, 100) var grid_size_y: int = 5:
	set(value):
		grid_size_y = value
		grid_resource.grid_size.y = value
		_update_grid_container()
@export var grid_resource: GridResource = GridResource.new():
	set(value):
		grid_resource = value
		_build_grid_from_resource()
@export var default_save_path: String = "res://resources/grid/"
@export_category("Nodes")
@export var grid_container: GridContainer
@export var editor_cell_scene: PackedScene
var cell_layout: Dictionary[Vector2i, int]
var padding: int = 10 
static var grid_resource_count: int = 0


func _ready() -> void:
	_build_grid_from_resource()
	_update_grid_container()


func _update_grid_container() -> void:
	if grid_container == null:
		return
	grid_container.columns = grid_size_y
	var cells = grid_container.get_children()
	for cell in cells:
		cell.queue_free()
	for i in range(grid_size_x * grid_size_y):
		var cell_node = editor_cell_scene.instantiate()
		cell_node.cell_position = Vector2i(i / grid_size_y, i % grid_size_y)
		if cell_layout.has(cell_node.cell_position):
			cell_node.activated = true
		grid_container.add_child(cell_node)


func _build_grid_from_resource() -> void:
	if grid_resource == null:
		return
	grid_size_x = grid_resource.grid_size.x
	grid_size_y = grid_resource.grid_size.y
	for i in grid_resource.cell_layout:
		cell_layout.get_or_add(i, 0)
	

func _change_cell_layout(cell_position: Vector2i, adding: bool):
	if adding:
		cell_layout.get_or_add(cell_position, 0)
	else:
		cell_layout.erase(cell_position)
	

## This function takes the grid that is currently being worked on in the editor and makes so that the
## limits of the grid are the cell with `min(x)`, the one with `min(y)`, the one with `max(x)`, and 
## the one with `max(y)`.
func _save_normalized_grid() -> void:
	var sorted_keys = cell_layout.keys()
	sorted_keys.sort_custom(func(x, y): return x.x < y.x)
	var min_x = sorted_keys[0].x
	var max_x = sorted_keys[-1].x
	sorted_keys.sort_custom(func(x, y): return x.y < y.y)
	var min_y = sorted_keys[0].y
	var max_y = sorted_keys[-1].y
	print_rich("[color=orange]final bounding coordinates: [/color](", min_x, ", ", min_y, "), (", max_x, ", ", max_y, ")")
	grid_resource.grid_size.x = abs(max_x - min_x + 1)
	grid_resource.grid_size.y = abs(max_y - min_y + 1)
	print_rich("[color=aquamarine]the grid will be reduced to ", grid_resource.grid_size.x, ", ", grid_resource.grid_size.y)
	var normalized_keys = cell_layout.keys()
	for i in range(normalized_keys.size()):
		normalized_keys[i] -= Vector2i(min_x, min_y)
	grid_resource.cell_layout.clear()
	for key in normalized_keys:
		grid_resource.cell_layout.get_or_add(key, 0)
	

func _on_editor_cell_pressed(cell: EditorCell) -> void:
	cell.activated = !cell.activated
	_change_cell_layout(cell.cell_position, cell.activated)


func _on_save_pressed() -> void:
	grid_resource.cell_layout = cell_layout
	print("previous grid layout: ", cell_layout)
	_save_normalized_grid()
	print("new grid layout: ", grid_resource.cell_layout)
	if not grid_resource.resource_path.ends_with(".tres"):
		var time = Time.get_datetime_string_from_system()
		grid_resource.take_over_path(default_save_path + "grid_" + time + ".tres")
		grid_resource = load(default_save_path + "grid_" + time + ".tres")
	ResourceSaver.save(grid_resource, grid_resource.resource_path)


# NOTE: this random generator function only generates grids that bound the max_word_size, and
# that have no blank space between attempts. To craft a crazier level, please use the editor.
# Further improvement in this sense could be made for the random generator.
static func generate_random_grid(min_word_size: int, max_word_size: int, attempts: int) -> GridResource:
	var resource = GridResource.new()
	var grid_size: Vector2i = Vector2i(attempts, max_word_size)
	var cell_layout: Dictionary[Vector2i, int] = {}
	for attempt in range(attempts):
		var columns = range(max_word_size)
		for i in range(randi_range(min_word_size, max_word_size)):
			var column = columns.pick_random()
			columns.erase(column)
			cell_layout[Vector2i(attempt, column)] = 0		
	resource.grid_size = grid_size
	resource.cell_layout = cell_layout
	return resource
