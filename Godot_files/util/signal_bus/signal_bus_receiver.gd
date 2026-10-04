class_name SignalBusReceiver
extends Node

signal keyboard_enter_pressed()
signal keyboard_delete_pressed()
signal keyboard_character_pressed()

signal editor_cell_pressed(cell: EditorCell)

signal winning_menu_next_level_pressed()

signal shop_manager_next_level_pressed(level: LevelTemplate)
signal shop_manager_item_bought(item: ShopItem)

signal main_menu_play_pressed()

signal level_manager_level_won()
signal level_manager_level_lost()

signal touch_gestures_pinch_detected(dist_diff: float)
signal touch_gestures_drag_detected(dist_vec: Vector2)


const GROUP := &'RECEIVER_GROUP'

static var _s_dirty := true
static var _s_receivers: Array[SignalBusReceiver] = []


func _enter_tree():
	add_to_group(GROUP)
	_s_dirty = true


func _exit_tree():
	_s_dirty = true


static func all(tree: SceneTree) -> Array[SignalBusReceiver]:
	if _s_dirty:
		_s_receivers.clear()
		for receiver: SignalBusReceiver in tree.get_nodes_in_group(GROUP):
			if receiver:
				_s_receivers.append(receiver)
		_s_dirty = false
	return _s_receivers
