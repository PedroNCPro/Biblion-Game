extends Node

@export var permanents_grid_container : GridContainer
@export var temporaries_grid_container : GridContainer
@export var challenges_grid_container : GridContainer
@export var inventory : Control

func _ready():
	inventory.hide()

func append_item(item: LevelItem, category: ShopItem.ItemType) -> void:
	if not item:
		push_warning("Attempted to append a null item.")
		return
		
	var target_grid = _get_grid_by_category(category)
	
	if target_grid:
		target_grid.add_child(item)

func remove_item(item: LevelItem) -> void:
	if is_instance_valid(item) and item.get_parent() is GridContainer:
		item.get_parent().remove_child(item)
		item.queue_free()

func clear_category(category: ShopItem.ItemType) -> void:
	var target_grid = _get_grid_by_category(category)
	for child in target_grid.get_children():
		if child is LevelItem:
			child.queue_free()

func _get_grid_by_category(category: ShopItem.ItemType) -> GridContainer:
	match category:
		ShopItem.ItemType.PERMANENT: return permanents_grid_container
		ShopItem.ItemType.TEMPORARY: return temporaries_grid_container
		ShopItem.ItemType.CHALLENGE: return challenges_grid_container
	return null

func _on_back_pressed() -> void:
	if inventory:
		inventory.visible = false

func _on_show_inventory_pressed() -> void:
	if inventory:
		inventory.visible = !inventory.visible
