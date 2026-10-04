extends Panel
class_name EditorCell


signal pressed(cell: EditorCell)
var cell_position: Vector2i
var activated: bool = false:
	set(value):
		activated = value
		_update_appearance()
@export var button: Button
@export var color_rect: ColorRect
@export var sender: SignalBusSender


func _ready() -> void:
	button.custom_minimum_size = custom_minimum_size
	_update_appearance()
	pressed.connect(sender.connect_signal)


func _update_appearance() -> void:
	if activated:
		color_rect.color = Color.DARK_SEA_GREEN
		return
	color_rect.color = Color.DARK_RED
	
	

func _on_button_pressed() -> void:
	if cell_position == null:
		push_error("this cell does not have a position associated to it")
	pressed.emit(self)
