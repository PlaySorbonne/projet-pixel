@tool
extends XYZ_ClickableHBox
class_name InfosTagline

enum ItemTypes {Character, Lore, Infos}

const ITEM_ICONS : Dictionary = {
	ItemTypes.Character : preload(
		"res://resources/images/interface/vault_items_icons/singleplayer.png"),
	ItemTypes.Lore : preload(
		"res://resources/images/interface/vault_items_icons/book_open.png"),
	ItemTypes.Infos : preload(
		"res://resources/images/interface/vault_items_icons/question.png")
}

@export var item_name := "item_name":
	set(value):
		item_name = value
		$Label.text = value
@export var item_type : ItemTypes = ItemTypes.Infos:
	set(value):
		item_type = value
		$Icon.texture = ITEM_ICONS[value]
@export_multiline var item_description := ""
@export var item_sprite : Texture
