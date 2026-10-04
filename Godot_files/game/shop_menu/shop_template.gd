extends Control
class_name ShopTemplate

func _ready():
	GameState.coins_changed.connect(func(coins): $Coins.text = "{coins} $".format({"coins": str(coins)}))
	GameState.coins = GameState.coins
