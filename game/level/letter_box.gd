extends Control
class_name LetterBox

#region Variables
const LETTERBOX_SCENE_PATH = "res://game/level/letter_box.tscn"

enum Status{
	EMPTY,
	FULL,
	DISABLED,
}

enum Correctness {
	NONE,
	WRONG,
	MISPLACED,
	CORRECT,
}

const STATUS_COLORS = {
	Status.EMPTY: Color(0.862, 0.849, 0.846),
	Status.FULL: Color(0.862, 0.849, 0.846),
	Status.DISABLED: Color(0.094, 0.094, 0.094, 0.0)
}

const CORRECTNESS_COLORS = {
	0 : Color(1.0, 1.0, 1.0),
	Correctness.WRONG: Color(0.549, 0.549, 0.549, 1.0),
	Correctness.MISPLACED: Color(0.94, 0.736, 0.0, 1.0),
	Correctness.CORRECT: Color(0.321, 0.74, 0.0, 1.0),
}

@export var state_machine: CellStateMachine

var status : Status = Status.EMPTY:
	set(status_v):
		status = status_v
		$TextureRect.modulate = STATUS_COLORS[status]
var correctness: Correctness = Correctness.NONE:
	set(value):
		correctness = value
		$PlacedLetter/LetterBackground.material.set_shader_parameter("clr", CORRECTNESS_COLORS[correctness])

@onready var bonus_points_anchor = $BonusPoints.position
var powerUp : LetterPowerUp = LetterPowerUp.new()

@onready var cell_element : LetterPowerUp.Element = LetterPowerUp.Element.None

#endregion

#region Private functions
func _ready() -> void :
	status = status
	$BonusPoints.modulate.a = 0.0
	$DiacriticBonusPoints.modulate.a = 0.0
	$Again.modulate.a = 0.0
#endregion

#region Public functions
func animate(pts_txt : String, should_diacritic : bool) -> void:
	var which_bonus_points = $BonusPoints
	if should_diacritic:
		$PlacedLetter/Diacritic.activate(0.0)
		which_bonus_points = $DiacriticBonusPoints
	else:
		$PlacedLetter/Letter.activate(0.0)
	which_bonus_points.position = bonus_points_anchor
	which_bonus_points.text = pts_txt
	which_bonus_points.modulate = Color(CORRECTNESS_COLORS[correctness])
	which_bonus_points.modulate.a = 1.0
	create_tween().tween_property(which_bonus_points, "position", bonus_points_anchor + Vector2(0.0, -30.0), 0.8)
	create_tween().tween_property(which_bonus_points, "modulate:a", 0.0, 0.8)

func again():
	$Again.position = bonus_points_anchor
	$Again.modulate.a = 1.0
	create_tween().tween_property($Again, "position", bonus_points_anchor + Vector2(0.0, -30.0), 0.8)
	create_tween().tween_property($Again, "modulate:a", 0.0, 0.8)

func update_diacritic(c : LetterPowerUp.Diacritic):
	if c != LetterPowerUp.Diacritic.None:
		var st = LetterPowerUp.string_of_diacritic[c]
		$PlacedLetter/Diacritic.set_char(st)
		$PlacedLetter/Diacritic.visible = true
		$PlacedLetter/Diacritic.position.y = { "~" : 12.0, "^" : 15.0, "¯" : 24.0, "¨" : 22.0 }[st]
		$PlacedLetter/Letter.position.y = 31.0
	else:
		$PlacedLetter/Letter.position.y = 27.0

func set_letter(c : String):
	if not c in RunManager.allPowerUps:
		powerUp.reset()
		powerUp.diacritic = LetterPowerUp.Diacritic.None
	else:
		var pw = RunManager.allPowerUps[c.to_upper()]
		powerUp.pattern = pw.pattern
		powerUp.element = pw.element
		powerUp.diacritic = pw.diacritic
	update_diacritic(powerUp.diacritic)
	$PlacedLetter/Letter.set_char(c)
	$PlacedLetter/Letter.set_element(int(powerUp.element))
	$PlacedLetter/Diacritic.set_element(int(powerUp.element))
	$PlacedLetter/LetterBackground.material.set_shader_parameter("which", powerUp.pattern)
	$PlacedLetter.visible = true

func reset():
	$PlacedLetter.visible = false
	$PlacedLetter/Diacritic.visible = false
	powerUp.reset()

func get_letter() -> String:
	return $PlacedLetter/Letter/Movable/Label.text.to_upper()

func set_impact_t(t : float) -> void:
	$Impact.material.set_shader_parameter("t", t)

func set_reaction_t(t : float) -> void:
	$Impact.material.set_shader_parameter("t_reaction", t)

func set_background_lerp(t : float) -> void:
	$TextureRect.material.set_shader_parameter("lerping", t)

func apply_element(which : LetterPowerUp.Element, is_reaction : bool, next_elem : LetterPowerUp.Element) -> void:
	if(cell_element == which):
		return
	$Impact.material.set_shader_parameter("which_elem", int(which))
	$TextureRect.material.set_shader_parameter("base_elem", int(cell_element))
	$TextureRect.material.set_shader_parameter("target_elem", int(which))
	$Impact.material.set_shader_parameter("which_a", int(cell_element))
	$Impact.material.set_shader_parameter("which_b", int(which))
	cell_element = next_elem
	$WaitForReaction.start()
	if is_reaction:
		create_tween().tween_method(set_reaction_t, 0.0, 1.0, 0.8)
		print("Go swap elem !")
		$SwapElement.start()
	else:
		create_tween().tween_method(set_impact_t, 0.0, 1.1, 0.8)
		create_tween().tween_method(set_background_lerp, 0.0, 1.0, 0.8)

## Instantiates a LetterBox.
##
## [param letter]: The letter to show.
## [param status_v]: The current Letterbox.Status of the letter.
## [returns]: an instance of LetterBox with the right parameters.
static func create(status_v : Status) -> LetterBox:
	var scene = load(LETTERBOX_SCENE_PATH)
	var node = scene.instantiate() as LetterBox
	node.status = status_v
	return node
#endregion

func _on_swap_element_timeout() -> void:
	$TextureRect.material.set_shader_parameter("base_elem", int(cell_element))
	print("Swap elem !")

func _on_wait_for_reaction_timeout() -> void:
	set_impact_t(0.0)
	$TextureRect.material.set_shader_parameter("base_elem", int(cell_element))
	set_background_lerp(0.0)
	
func get_random_power_up():
	$PlacedLetter/Letter.set_char(char(ord('A') + randi_range(0, ord('Z') - ord('A'))))
	powerUp.diacritic = randi_range(0, 4)
	powerUp.element = randi_range(0, 4)
	powerUp.pattern = randi_range(0, 4)
	while (
		powerUp.diacritic == 0 
		and powerUp.element == 0
		and powerUp.pattern == 0
	):
		powerUp.diacritic = randi_range(0, 4)
		powerUp.element = randi_range(0, 4)
		powerUp.pattern = randi_range(0, 4)
	if powerUp.element == LetterPowerUp.Element.None:
		powerUp.pattern = LetterPowerUp.Pattern.None
	update_diacritic(powerUp.diacritic)
	
	$PlacedLetter/Letter.set_element(int(powerUp.element))
	$PlacedLetter/Diacritic.set_element(int(powerUp.element))
	$PlacedLetter/LetterBackground.material.set_shader_parameter("which", powerUp.pattern)
	$TextureRect.visible = false
	$PlacedLetter.visible = true
