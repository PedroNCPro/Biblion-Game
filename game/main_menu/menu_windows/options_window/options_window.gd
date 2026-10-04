extends MenuWindow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/MarginContainer/WindowContent/HighContrastButton.button_pressed = GlobalThemes.is_high_contrast_enabled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_high_contrast_button_toggled(toggled_on: bool) -> void:
	GlobalThemes.enable_high_contrast(toggled_on)
