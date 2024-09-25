@tool
extends HBoxContainer
class_name ShopItem

enum ItemTypes {GameMode, Minigame, Level, Art, Music, StatEditor}

const ITEM_ICONS : Dictionary = {
	ItemTypes.GameMode : preload(
		"res://resources/images/interface/vault_items_icons/massiveMultiplayer.png"),
	ItemTypes.Minigame : preload(
		"res://resources/images/interface/vault_items_icons/joystickRight.png"),
	ItemTypes.Level : preload(
		"res://resources/images/interface/vault_items_icons/structure_gate.png"),
	ItemTypes.Art : preload(
		"res://resources/images/interface/vault_items_icons/movie.png"),
	ItemTypes.Music : preload(
		"res://resources/images/interface/vault_items_icons/musicOn.png"),
	ItemTypes.StatEditor : preload(
		"res://resources/images/interface/vault_items_icons/flask_half.png")
}

@export var item_name := "item_name":
	set(value):
		item_name = value
		$Label.text = value
@export var item_type : ItemTypes = ItemTypes.GameMode:
	set(value):
		item_type = value
		$Icon.texture = ITEM_ICONS[value]
@export var price : int = 100:
	set(value):
		price = value
		$PricePanel/PriceLabel.text = str(value)
