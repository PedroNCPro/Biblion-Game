extends Control
class_name LevelInventory


@export var permanent_items_grid: GridContainer
var power_ups: Array[ShopItem]


func setup() -> void:
	var run_manager = RunManager
	for item in run_manager.power_ups:
		if item.get_parent():
			item.get_parent().remove_child(item)
		permanent_items_grid.add_child(item)
		item.item_selected.connect(_on_selected_item.bind(item))
		
		
func _on_selected_item(item: ShopItem):
	var modal_window = ModalShopItemWindow.create(item)
	modal_window.buy_button.visible = false
	modal_window.back_pressed.connect(func():modal_window.queue_free())
	get_parent().add_child(modal_window)
	move_child(modal_window,get_parent().get_child_count())
