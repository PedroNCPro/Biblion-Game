extends Control
class_name Keyboard

#region Variables
const KEYBOARD_SCENE_PATH = "res://game/level/keyboard.tscn"

var _key_rows : Array[HBoxContainer] = []
var _string_rows : Array[String] = ["AZERTYUIOP", "QSDFGHJKLM", "WXCVBN"]
var _keys : Array[KeyboardKey] = []
var interaction_blocked := false
#endregion

#region Signals
## Emitted when the user wants to confirm something.
signal enter_pressed
## Emitted when the user wants to delete something.
signal delete_pressed
## Emitted when the user types a character on the Keyboard.
##
## [param c]: transmitted character.
signal character_pressed(c :String)
#endregion

#region Private functions
func _ready() -> void:
	_key_rows.append($VBoxContainer/row1)
	_key_rows.append($VBoxContainer/row2)
	_key_rows.append($VBoxContainer/row3)
	assert(len(_string_rows) == len(_key_rows), "string rows and key rows are not equal !")
	
	for i in range(len(_key_rows)):
		var row = _key_rows[i]
		for key_text in _string_rows[i]:
			var key = KeyboardKey.create(key_text)
			row.add_child(key)
			_keys.append(key)
			key.key_pressed.connect(_on_char_pressed)


# Updates letter color based on secret word correctness
func update_letter(letter: String, correctness: LetterBox.Correctness):
	var key = get_key(letter)
	var button: Button = key.find_child("Button")
	for stylebox_string in ["normal", "pressed", "hover"]:
		var new_stylebox = button.get_theme_stylebox(stylebox_string).duplicate()
		if new_stylebox is StyleBoxFlat:
			new_stylebox.bg_color = LetterBox.CORRECTNESS_COLORS[correctness]
		button.add_theme_stylebox_override(stylebox_string, new_stylebox)
	#button.modulate = LetterBox.CORRECTNESS_COLORS[correctness]
	#button.add_theme_stylebox_override("normal", new_stylebox)


func _on_enter_button_up() -> void:
	if interaction_blocked:
		return
	enter_pressed.emit()


func _on_del_button_up() -> void:
	if interaction_blocked:
		return
	delete_pressed.emit()


func _on_char_pressed(c : String) -> void:
	if interaction_blocked:
		return
	character_pressed.emit(c)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		if key_name.length() == 1 and key_name.is_valid_identifier():
			_on_char_pressed(key_name)
		elif key_name == "Enter":
			_on_enter_button_up()
		elif key_name == "Backspace":
			_on_del_button_up()
#endregion

#region Public functions
## Gets the first LETTER KeyboardKey based on its letter.
##
## [param c]: researched character.
## [returns]: the first KeyboardKey of the keyboard with the same character, else null.
func get_key(c : String):
	for key in _keys:
		if key.key_text == c :
			return key
	return null

# Resets the Keyboard.
func reset() -> void:
	for key in _keys:
		key.queue_free()
	_key_rows.clear()
	_keys.clear()
	_ready()

## Instantiate a Keyboard.
##
## [returns] an instance of Keyboard.
static func create() -> Keyboard:
	return load(KEYBOARD_SCENE_PATH).instantiate()
#endregion
