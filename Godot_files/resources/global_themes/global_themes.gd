extends Node

@export var regular_text_theme: Theme
@export var main_color_1: Color
@export var current_theme: Theme
@export var main_theme_lc: Theme
@export var main_theme_hc: Theme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enable_high_contrast(turn_on):
	if(turn_on):
		regular_text_theme.set_constant("outline_size", "Label", 3)
		regular_text_theme.set_constant("outline_size", "CheckButton", 3)
		apply_theme_from(main_theme_hc)
	else:
		regular_text_theme.set_constant("outline_size", "Label", 0)
		regular_text_theme.set_constant("outline_size", "CheckButton", 0)
		apply_theme_from(main_theme_lc)
	ResourceSaver.save(regular_text_theme)
	ResourceSaver.save(current_theme, current_theme.resource_path)


func is_high_contrast_enabled():
	return regular_text_theme.get_constant("outline_size", "Label") > 0


func apply_theme_from(other: Theme):
# Colors
	for type in other.get_color_type_list():
		for name in other.get_color_list(type):
			current_theme.set_color(name, type, other.get_color(name, type))

# Fonts
	for type in other.get_font_type_list():
		for name in other.get_font_list(type):
			current_theme.set_font(name, type, other.get_font(name, type))

# Styleboxes
	for type in other.get_stylebox_type_list():
		for name in other.get_stylebox_list(type):
			current_theme.set_stylebox(name, type, other.get_stylebox(name, type))

# Constants
	for type in other.get_constant_type_list():
		for name in other.get_constant_list(type):
			current_theme.set_constant(name, type, other.get_constant(name, type))

	for type in other.get_type_list():
		for name in other.get_type_variation_list(type):
			current_theme.set_type_variation(name, type)
