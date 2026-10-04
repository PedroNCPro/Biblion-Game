extends Control
class_name Milestone

var _description : String = "---------":
	set(v):
		_description = v
		$HBoxContainer/MilestoneText.text = _description
var _coins_value : String = "~":
	set(v):
		_coins_value = v
		$HBoxContainer/MilestoneCoins.text = _coins_value
	
static func create(description : String, value : String) -> Milestone:
	var scene = load("res://game/level/milestone.tscn")
	var node = scene.instantiate() as Milestone
	node._description = description
	node._coins_value = value
	return node
	
