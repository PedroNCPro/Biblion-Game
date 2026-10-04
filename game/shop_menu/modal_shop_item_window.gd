extends Control

class_name ModalShopItemWindow

const MODAL_SHOP_ITEM_WINDOW_SCENE_PATH : String = "res://game/shop_menu/modal_shop_item_window.tscn"

signal buy_pressed
signal back_pressed

@export var buy_button: Button

static func create(shop_item : ShopItem) -> ModalShopItemWindow:
	var scene = load(MODAL_SHOP_ITEM_WINDOW_SCENE_PATH)
	var node = scene.instantiate() as ModalShopItemWindow
	node.get_node("Description").text = shop_item.description
	node.get_node("BuyButton").text = "Buy ({price})".format({"price": shop_item.price})
	node.get_node("Name").text = shop_item.item_name
	node.get_node("ItemImage").texture = shop_item.icon
	return node

func _on_buy_button_pressed() -> void:
	buy_pressed.emit()
	
	

func _on_back_pressed() -> void:
	back_pressed.emit()
