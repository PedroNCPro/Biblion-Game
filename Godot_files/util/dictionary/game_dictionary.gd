extends Node
## Class for loading a dictionary into the game and consulting it. It provides an API for
## consulting whether a word is or not in the dictionary, and also to randomly pick words.

const DICTIONARY_FILE_PATH = "res://util/dictionary/english_dictionary_2.json"
var words: Dictionary = {}
var plurals: Dictionary = {}


func _ready() -> void:
	_load_dictionary(DICTIONARY_FILE_PATH)


func pick_random_word_of_size(size: int) -> String:
	return words[str(size)].keys().pick_random()


func is_word_in_dictionary(word: String) -> bool:
	var word_size = word.length()
	return words[str(word_size)].has(word)


func is_word_or_plural_in_dictionary(word: String) -> bool:
	var word_size = word.length()
	return words[str(word_size)].has(word) \
		or plurals.has(word)
	

func get_word_data(word: String) -> Dictionary:
	if not is_word_in_dictionary(word):
		return {}
	var word_size = word.length()
	return words[str(word_size)][word]


func format_word_data(word_data: Dictionary) -> String:
	var bbcode = ""
	if word_data.has("meanings"):
		bbcode += "[p][font_size=24][b]Definitions[/b][/font_size][/p]\n"
		
		for meaning in word_data["meanings"]:
			var part_of_speech = meaning["speech_part"]
			var definition = meaning["def"] + "."
			
			bbcode += "[color=blue][i]" + part_of_speech + "[/i][/color]: "
			bbcode += definition + "\n"
			bbcode += "\n"
	if word_data.has("synonyms") and word_data["synonyms"].size() > 0:
		bbcode += "[b][color=dark_green]Synonyms:[/color][/b] "
		bbcode += ", ".join(word_data["synonyms"]) + "\n\n"
	
	if word_data.has("antonyms") and word_data["antonyms"].size() > 0:
		bbcode += "[b][color=red]Antonyms:[/color][/b] "
		bbcode += ", ".join(word_data["antonyms"]) + "\n"
	return bbcode


func get_formatted_word_data(word: String) -> String:
	var word_data = get_word_data(word)
	if word_data == {}:
		return ""
	return format_word_data(word_data)


func _load_dictionary(path: String) -> void:
	if not FileAccess.file_exists(path):
		print("Dictionary file does not exist.")
		return
	var data_file = FileAccess.open(path, FileAccess.READ)
	var parsed_result = JSON.parse_string(data_file.get_as_text())
	if not parsed_result is Dictionary:
		print("Error loading dictionary.")
		return 
	words = parsed_result
	
	# TODO make this in a cleaner way
	for l_size in words.keys():
		for word in words[l_size]:
			if words[l_size][word].has("plural"):
				plurals[words[l_size][word]["plural"]] = words[l_size][word]["word"]
