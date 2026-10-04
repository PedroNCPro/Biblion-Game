extends MenuWindow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/MarginContainer/WindowContent/HBoxContainer/HighestScoreLabel.text = str(GameState.highest_score) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
