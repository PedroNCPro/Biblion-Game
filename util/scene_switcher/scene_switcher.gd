extends Node
## This class is a singleton for changing scenes. From the inspector, 
## set all the possible scenes for the [SceneSwitcher] to change to.
## Then, to change to a given scene, call the respective function to do so,
## and [SceneSwitcher] will deal with all the process of replacing the root nodes,
## as well as calling the respective setup methods for each one.


@export var main_menu_scene: PackedScene
@export var level_scene: PackedScene
@export var shop_scene: PackedScene

var current_scene_root: Node


func go_to_main_menu():
	var main_menu_root = main_menu_scene.instantiate()
	_change_to_scene(main_menu_root)


func go_to_shop():
	var shop_root = shop_scene.instantiate()
	_change_to_scene(shop_root)


func _change_to_scene(node: Node):
	current_scene_root.queue_free()
	await current_scene_root.tree_exited
	current_scene_root = node
	get_tree().root.add_child(node)
