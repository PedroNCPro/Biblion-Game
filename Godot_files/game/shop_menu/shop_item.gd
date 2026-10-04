extends Control
class_name ShopItem

enum ItemType{
	PERMANENT,
	TEMPORARY,
	CHALLENGE,
}

#region Signals
signal item_selected
#endregion

#region Variables
var item_name : String = "test title":
	set(item_name_v):
		item_name = item_name_v
		_update_display(item_name, description)
var description : String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.":
	set(description_v):
		description = description_v
		_update_display(item_name, description)
var price : int = 0
var i : int = 0
var icon : Texture2D = preload("res://assets/icon.svg"):
	set(icon_v):
		icon = icon_v
		if icon != null:
			$TextureButton.texture_normal = icon
		_apply_click_mask()
		
const ITEM_SCENE_PATH : String = "res://game/shop_menu/shop_item.tscn"
var item_type : ItemType = ItemType.TEMPORARY
#endregion

#region Private functions
func _apply_click_mask():
	if icon == null:
		return
	var bitmap = BitMap.new()
	var image = icon.get_image()
	bitmap.create_from_image_alpha(image)
	$TextureButton.texture_click_mask = bitmap

func _update_display(titre: String, desc: String):
	var template = "[center][b][font_size=24]{nom}[/font_size][/b]\n\n{info}[/center]"
	var final_text = template.format({"nom": titre, "info": desc})
	$PanelContainer/MarginContainer/Description.text = final_text

func _on_texture_button_pressed() -> void:
	item_selected.emit()
#endregion

#region Public functions
static func create(p_name: String, p_desc: String, p_price: int, p_tex: Texture2D) -> ShopItem:
	var scene = load(ITEM_SCENE_PATH)
	var node = scene.instantiate()
	node.item_name = p_name
	node.description = p_desc
	node.price = p_price
	node.icon = p_tex
	return node
	
"""
enum Element {
	None, Fire, Water, Air, Earth
}

enum Diacritic {
	None, Tilde, Circumflex, Dieresis, Macron
}

enum Pattern {
	None, Square, Cross, Column, Line
}
"""

static func create_random_permanent() -> ShopItem:
	const string_of_elem : Array[String]      = ["nothing", "fire", "water", "a storm", "vegetation"]
	const string_of_pattern : Array[String]   = ["its grid cell", "the adjacent grid cells", "its two grid diagonals",  "the entire column", "the entire row"]
	const string_of_diacritic : Array[String] = ["bruh", "Tilde : doubles the score", "Circumflex : gives 50 points", "Dieresis : gives a random amount of points", "Macron : shuffles the digits of the score"]
	var scene = load(ITEM_SCENE_PATH)
	var node : ShopItem = scene.instantiate()
	var lb : LetterBox = node.get_node("LetterBox")
	lb.get_random_power_up()
	
	node.item_name = lb.get_node("PlacedLetter/Letter").get_char()[0]
	node.price = randi_range(2, 4)
	node.description = node.item_name
	if lb.powerUp.element != LetterPowerUp.Element.None:
		node.description += " : applies " + string_of_elem[int(lb.powerUp.element)] + " to " + string_of_pattern[int(lb.powerUp.pattern)]
		node.price += randi_range(1, 3)
		if lb.powerUp.pattern != LetterPowerUp.Pattern.None:
			node.price += randi_range(1, 3)
	if lb.powerUp.diacritic != LetterPowerUp.Diacritic.None:
		node.price += randi_range(1, 3)
		node.description += "\n" + string_of_diacritic[int(lb.powerUp.diacritic)]
	node.price = floori(node.price / 2)

	lb.visible = true
	
	return node
#endregion
