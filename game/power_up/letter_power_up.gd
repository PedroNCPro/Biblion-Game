extends PowerUp
class_name LetterPowerUp

enum Element {
	None, Fire, Water, Air, Earth
}

enum Diacritic {
	None, Tilde, Circumflex, Dieresis, Macron
}

enum Pattern {
	None, Square, Cross, Column, Line
}

@onready var element : Element = Element.None
@onready var diacritic : Diacritic = Diacritic.None
@onready var pattern : Pattern = Pattern.None

func reset() -> void:
	element = Element.None
	diacritic = Diacritic.None
	pattern = Pattern.None

const string_of_diacritic = {
	LetterPowerUp.Diacritic.None : " ",
	LetterPowerUp.Diacritic.Tilde : "~",
	LetterPowerUp.Diacritic.Circumflex : "^",
	LetterPowerUp.Diacritic.Macron : "¯",
	LetterPowerUp.Diacritic.Dieresis : "¨"
}
