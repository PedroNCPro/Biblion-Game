extends HBoxContainer

@export var label: String
@export var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	$VolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	$Label.text = label

func _on_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
