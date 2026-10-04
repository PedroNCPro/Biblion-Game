extends Node
class_name LevelManager

# this class deals with the logic of the _current_ level. That means:
# - it comprises everything that is data, as opposed to visual elements
# - it generates a random secret word in such a way that is coherent to the grid's layout (size and position of the last row)
# - it checkes for words in the dictionary with every attempt
# - it calls the right functions for typing letters (LetterBox)
# - it keeps track of how many points the player has
# - it keeps track of the "challenges" the player has to complete to gain coins (coin power-ups)
# - it keeps track of word resolution (ordering of effect resolution function calls, total number of points scored, etc.)

signal level_won
signal level_lost

@export var receiver: SignalBusReceiver
@export var winning_menu: WinningMenuUI
@export var game_over: Control
@export var blackout: ColorRect
@export var score: Control
@export var invalid_guess_label: Label
@export var invalid_guess_timer: Timer

var next_cell_to_fill_idx: int = 0
var current_row: int = 0
var current_guess: String = ""
var correct_letters_in_guess: int = 0
var grid: Grid
var keyboard: Keyboard
var secret_word: Dictionary[String, Array] # (character, list of column indices this character occurs)
var secret_word_string: String
var point_threshold: int
var current_points: int
var secret_word_bonus : int = 2 # this is the multiplier applied to points when guessing the right word
var known : Array[String] = []

class Update:
	var letter : LetterBox
	var where : Vector2i
	var should_diacritic : bool
	var should_elem : bool
	var should_guess : bool
	var apply_element : LetterPowerUp.Element

static func init_update(l : LetterBox, w : Vector2i, sh_diacritic : bool, sh_elem : bool, sh_guess : bool, ap_element : LetterPowerUp.Element) -> Update:
	var u := Update.new()
	u.letter = l
	u.where = w
	u.should_diacritic = sh_diacritic
	u.should_elem = sh_elem
	u.should_guess = sh_guess
	u.apply_element = ap_element
	return u

var update_queue : Array[Update]

func choose_secret_word() -> void: 
	if not grid:
		push_error("there is no grid for generating secret word!")
	var last_row: int = -1
	for coord in grid.cell_layout.keys():
		last_row = max(last_row, coord.x)
	var last_row_cells = grid.get_row(last_row)
	secret_word_string = GameDictionary.pick_random_word_of_size(last_row_cells.size())
	for i in secret_word_string.length():
		secret_word.get_or_add(secret_word_string[i], []).append(last_row_cells.keys()[i].y)
	winning_menu.set_definition(GameDictionary.get_formatted_word_data(secret_word_string))
	winning_menu.set_word(secret_word_string)
	print("secret word is: ", secret_word_string)
	print(secret_word)
	

func get_next_cell_to_fill() -> void:
	return grid.get_cell_by_index(next_cell_to_fill_idx)


# TODO think of a better way of dealing with the points, like having a "base_points"
# based on letter judgement, then resolve the effects as a list of functions that take
# those "base_points" and return the modified value to chain with the next effect or something like that.
func resolve_guess() -> void:
	keyboard.interaction_blocked = true
	var row_letters := grid.get_row(current_row)
	
	for coord in row_letters:
		update_queue.push_back(init_update(row_letters[coord], coord, true, true, true, LetterPowerUp.Element.None))

	for no_infinite_loop in range(42):
		if len(update_queue) <= 0:
			break
		var up = update_queue.pop_front()
		await _resolve_letter_effect(up)
	update_queue = []
	
	if correct_letters_in_guess == current_guess.length() and current_guess.length() == secret_word_string.length():
		current_points *= secret_word_bonus
		score.update_points(current_points)
	
	keyboard.interaction_blocked = false
	if _get_next_row() == current_row:
		if current_points >= point_threshold:
			_win()
		else:
			_lose()	
	correct_letters_in_guess = 0
	current_guess = ""


func _resolve_letter_guess(coordinates: Vector2i, letter: LetterBox):
	var points := 0
	if letter.get_letter() in secret_word.keys():
		if coordinates.y in secret_word[letter.get_letter()]:
			letter.correctness = LetterBox.Correctness.CORRECT
			print(letter.correctness)
			correct_letters_in_guess += 1
			points += 10
		else:
			letter.correctness = LetterBox.Correctness.MISPLACED
			points += 5
	else:
		letter.correctness = LetterBox.Correctness.WRONG
		points += 1
	keyboard.update_letter(letter.get_letter(), letter.correctness)
	return points
	
func shuffle_string(s):
	randomize()
	var a = []
	for c in s: a.append(c)
	a.shuffle()
	return "".join(a)

func resolve_diacritic(letter : LetterBox) -> bool:
	match letter.powerUp.diacritic:
		LetterPowerUp.Diacritic.Tilde:
			letter.animate("x2", true)
			current_points *= 2
			score.update_points(current_points)
		LetterPowerUp.Diacritic.Circumflex:
			letter.animate("+50", true)
			current_points += 50
			score.update_points(current_points)
		LetterPowerUp.Diacritic.Dieresis:
			var pt = randi_range(1, 100)
			letter.animate("+" + str(pt), true)
			current_points += pt
			score.update_points(current_points)
		LetterPowerUp.Diacritic.Macron:
			letter.animate("+???", true)
			current_points = int(shuffle_string(str(current_points)))
			score.update_points(current_points)
	return letter.powerUp.diacritic != LetterPowerUp.Diacritic.None

func resolve_element(coordinates: Vector2i, letter: LetterBox):
	if letter.powerUp.element == LetterPowerUp.Element.None:
		return

	var apply_to_who : Dictionary[Vector2i, LetterBox] = { coordinates : letter }

	match letter.powerUp.pattern:
		LetterPowerUp.Pattern.Line:
			apply_to_who = grid.get_row(coordinates.x)
		LetterPowerUp.Pattern.Column:
			apply_to_who = grid.get_column(coordinates.y)
		LetterPowerUp.Pattern.Cross:
			apply_to_who = grid.get_cross(coordinates)
		LetterPowerUp.Pattern.Square:
			apply_to_who = grid.get_neighbours(coordinates)

	for curr in apply_to_who:
		update_queue.push_front(init_update(apply_to_who[curr], curr, false, false, false, letter.powerUp.element))


func resolve_reaction(coordinates: Vector2i, letter: LetterBox, incoming : LetterPowerUp.Element) -> bool:
	if incoming == letter.cell_element: return false
	var is_reaction := not (letter.cell_element == LetterPowerUp.Element.None)
	
	var next_elem = incoming
	if is_reaction:
		var a = letter.cell_element if int(letter.cell_element)  < int(incoming) else incoming
		var b = letter.cell_element if int(letter.cell_element) >= int(incoming) else incoming
		match [a, b]:
			[LetterPowerUp.Element.Fire, LetterPowerUp.Element.Water]:
				current_points += 50
				score.update_points(current_points)
				next_elem = LetterPowerUp.Element.Water
			[LetterPowerUp.Element.Fire, LetterPowerUp.Element.Air]:
				next_elem = LetterPowerUp.Element.None
				letter.again()
				update_queue.push_front(init_update(letter, coordinates, true, true, false, LetterPowerUp.Element.None))
			[LetterPowerUp.Element.Fire, LetterPowerUp.Element.Earth]:
				next_elem = LetterPowerUp.Element.Fire
				var neighbours = [coordinates + Vector2i(-1, 0), coordinates + Vector2i(1, 0), coordinates + Vector2i(0, -1), coordinates + Vector2i(0, 1)]
				for n in neighbours:
					var tmpl : LetterBox = grid.get_cell_by_coordinates(n.x, n.y)
					if tmpl and tmpl.status != LetterBox.Status.DISABLED and tmpl.cell_element == LetterPowerUp.Element.Earth:
						update_queue.push_front(init_update(tmpl, n, false, false, false, LetterPowerUp.Element.Fire))
			[LetterPowerUp.Element.Water, LetterPowerUp.Element.Air]:
				next_elem = LetterPowerUp.Element.None
				update_queue.push_front(init_update(letter, coordinates, true, false, false, LetterPowerUp.Element.None))
				letter.again()
			[LetterPowerUp.Element.Water, LetterPowerUp.Element.Earth]:
				secret_word_bonus += 1
				next_elem = LetterPowerUp.Element.Earth
			[LetterPowerUp.Element.Air, LetterPowerUp.Element.Earth]:
				next_elem = LetterPowerUp.Element.None
				update_queue.push_front(init_update(letter, coordinates, false, true, false, LetterPowerUp.Element.None))
				letter.again()
		
	letter.apply_element(incoming, is_reaction, next_elem)

	return true

func _resolve_letter_effect(up : Update) -> void:
	if up.should_guess:
		var tmp_points = _resolve_letter_guess(up.where, up.letter)
		up.letter.animate("+" + str(tmp_points), false)
		current_points += tmp_points
		score.update_points(current_points)
		await get_tree().create_timer(0.3).timeout
	if up.should_diacritic:
		if resolve_diacritic(up.letter):
			await get_tree().create_timer(0.3).timeout
	if up.apply_element != LetterPowerUp.Element.None:
		var wait_time : float = 0.3 if up.letter.cell_element == LetterPowerUp.Element.None else 0.8
		if resolve_reaction(up.where, up.letter, up.apply_element):
			await get_tree().create_timer(wait_time).timeout
	elif up.should_elem:
		resolve_element(up.where, up.letter)


func _get_next_row() -> int:
	print("current row is ", current_row)
	var idx = grid.resource.cell_layout.keys().find_custom(func(x): return x.x > current_row)
	print("next row is ", grid.resource.cell_layout.keys()[idx].x)
	if idx == -1:
		return current_row
	return grid.resource.cell_layout.keys()[idx].x


func _is_last_cell_in_row() -> bool:
	return next_cell_to_fill_idx >= grid.get_cell_count() \
		or grid.resource.cell_layout.keys()[next_cell_to_fill_idx].x > current_row


func _is_valid_guess() -> bool:
	return _is_last_cell_in_row() \
		and GameDictionary.is_word_or_plural_in_dictionary(current_guess) \
		and (known.find(current_guess) == -1)
	

func _win() -> void:
	blackout.visible = true
	winning_menu.visible = true
	keyboard.interaction_blocked = true
	print("bouta win man")
	if current_points > GameState.highest_score:
		GameState.highest_score = current_points
	level_won.emit()
	

func _lose() -> void:
	blackout.visible = false
	game_over.visible = true
	keyboard.interaction_blocked = true	
	level_lost.emit()


func _show_invalid_guess() -> void:
	print("not a valid guess")
	invalid_guess_label.visible = true
	invalid_guess_timer.start(1)
	await invalid_guess_timer.timeout
	invalid_guess_label.visible = false
	

func _on_keyboard_character_pressed(c: String) -> void:
	if _is_last_cell_in_row():
		return
	current_guess += c 
	var letter_box := grid.get_cell_by_index(next_cell_to_fill_idx)
	next_cell_to_fill_idx += 1
	letter_box.set_letter(c)
	letter_box.status = LetterBox.Status.FULL


func _on_keyboard_delete_pressed() -> void:
	if current_guess == "":
		return
	current_guess = current_guess.erase(current_guess.length() - 1, 1)
	next_cell_to_fill_idx -= 1
	var letter_box := grid.get_cell_by_index(next_cell_to_fill_idx)
	letter_box.reset()
	letter_box.status = LetterBox.Status.EMPTY
	

func _on_keyboard_enter_pressed() -> void:
	if not _is_valid_guess():
		_show_invalid_guess()
		return
	known.push_back(current_guess)
	await resolve_guess()
	current_row = _get_next_row()
