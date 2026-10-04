extends Control
class_name LevelItem

# Attributes
var shop_name: String
var description: String
var image_texture: Texture2D

@onready var texture_button: TextureButton = $TextureButton
@onready var label : Label = $PanelContainer/MarginContainer/Label
@onready var label_panel : PanelContainer = $PanelContainer
static func create(p_name: String, p_description: String, p_image: Texture2D) -> LevelItem:
	var scene = load("./level_item.tscn")
	var instance = scene.instantiate() as LevelItem
	
	instance.shop_name = p_name
	instance.description = p_description
	instance.image_texture = p_image
	
	return instance



func _ready() -> void:
	if texture_button and image_texture:
		texture_button.texture_normal = image_texture

func _on_texture_button_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		label_panel.show()
	else :
		label_panel.hide()

func _on_hidden() -> void:
	label_panel.hide()
