extends Resource
class_name LevelResource
## Resource for storing information about a level to be created.
##
## Stores values and scenes to build a level to be played.


@export_group("Parameters")
## Number of points the player has to achieve in this level to win it.
@export_range(0, 1e10, 1, "hide_slider") var points_to_win: int = 0 
## Number of letters in the secret word. Note that setting[br]
## [member LevelResource.secret_word] will have priority over this.
@export_range(1, 10000, 1, "hide_slider") var word_size: int = 5
## The secret word the player has to guess for this level.[br]
## Note that setting it will have priority over setting parameters for a random[br]
## word generation.
@export var secret_word: String 
## Number of attempts the player has to guess the secret word.
@export_range(1, 10000, 1, "hide_slider") var number_of_tries: int = 7

@export_group("Scenes")
@export var background_scene: PackedScene
@export var keyboard_scene: PackedScene
@export var grid_scene: PackedScene
