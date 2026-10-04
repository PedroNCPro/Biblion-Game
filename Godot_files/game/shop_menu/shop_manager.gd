extends Node
class_name ShopManager

signal next_level_pressed(level: LevelTemplate)
signal item_bought(item: ShopItem)
@export var next_level_label : Label
@export var threshold_prefix: String = "Next level threshold \n"
@export var permanents_container : HBoxContainer
@export var temporaries_container : HBoxContainer
@export var challenges_container : HBoxContainer
@export var MAX_ITEMS_PER_TYPES : int = 3
#region Variables
var _shop_items_available : Array[ShopItem] = []
var next_level: LevelTemplate
#endregion

func _ready() -> void :
	# append_item(ShopItem.create("caca","cacaprout", 100,preload("res://assets/icon.svg")))
	for i in range(3):
		append_item(ShopItem.create_random_permanent())
	next_level = RunManager._create_next_level()
	update_threshold_display(next_level.point_threshold)
	
#region Private functions
	
func _on_selected_item_do(item : ShopItem) -> void:
	var modal_window = ModalShopItemWindow.create(item)
	modal_window.buy_pressed.connect(func():
		_on_buy_item(item)
		modal_window.queue_free()
	)
	modal_window.back_pressed.connect(func():modal_window.queue_free())
	get_parent().add_child(modal_window)
	move_child(modal_window,get_parent().get_child_count())


func _on_buy_item(item : ShopItem) -> void:
	if GameState.coins < item.price:
		print("could not buy item : not enough funds !")
		return
	GameState.coins -= item.price
	var idx = _shop_items_available.find(item)
	if idx != -1:
		var bought_item = remove_item(idx)
		RunManager.allPowerUps[item.get_node("LetterBox/PlacedLetter/Letter").get_char()[0]] = item.get_node("LetterBox").powerUp
		item_bought.emit(item)
		print("Purchase suceeded : {n}".format({"n": item.item_name}))
	else:
		print("Error : item not found in the shop.")
	# TODO: Implement the buy action
	
func _on_next_level_pressed() -> void:
	next_level_pressed.emit(next_level)
#endregion

#region Public functions
func append_item(item : ShopItem) -> void:
	var target_container : HBoxContainer = null
	match item.item_type:
		ShopItem.ItemType.PERMANENT: target_container = permanents_container
		ShopItem.ItemType.TEMPORARY: target_container = temporaries_container
		ShopItem.ItemType.CHALLENGE: target_container = challenges_container

	if target_container and target_container.get_child_count() < MAX_ITEMS_PER_TYPES:
		target_container.add_child(item)
		_shop_items_available.append(item)
		item.item_selected.connect(_on_selected_item_do.bind(item))
	else:
		print("Impossible to add {n} : not found or full.".format({"n": item.item_name}))


func remove_item(index : int) -> ShopItem:
	var item : ShopItem = _shop_items_available[index]
	_shop_items_available.remove_at(index)
	match item.item_type:
		ShopItem.ItemType.PERMANENT : permanents_container.remove_child(item); return item
		ShopItem.ItemType.TEMPORARY : temporaries_container.remove_child(item); return item
		ShopItem.ItemType.CHALLENGE : challenges_container.remove_child(item); return item
		_ : return null

		
func get_items(index : int) -> ShopItem:
	return _shop_items_available[index]


func update_threshold_display(value: Variant):
	next_level_label.text = "%s %s" % [threshold_prefix, str(value)]
#endregion
