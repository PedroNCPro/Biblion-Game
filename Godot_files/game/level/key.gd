extends Control
class_name KeyboardKey

#region Variables
const KEY_SCENE_PATH = "res://game/level/key.tscn"

## The character displayed on the key.
var key_text : String = "~" :
	set(key_val):
		key_text = key_val
		if has_node("Button"):
			$Button.text = key_text
#endregion

#region Signals
## Emitted when the user presses or releases the key.
##
## [param key_text]: The character value of the key (e.g., "A", "ENTER").
signal key_pressed(key_text : String)
#endregion

#region Private functions

func _ready() -> void:
	key_text = key_text

func _on_button_button_up() -> void:
	key_pressed.emit(key_text)
#endregion

#region Public functions
## Instantiates a keyboard key.
##
## [param letter_v]: The single character to display.
## [param status_v]: The initial KeyboardKey.Status (defaults to EMPTY).
## [returns]: a KeyboardKey instance if exists, null if not.
static func create(key_val: String) -> KeyboardKey :
	var scene = load(KEY_SCENE_PATH)
	var key_node = scene.instantiate()
	key_node.key_text = key_val
	return key_node
#endregion
