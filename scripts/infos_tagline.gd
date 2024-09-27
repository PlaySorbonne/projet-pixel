@tool
extends XYZ_ClickableHBox
class_name InfosTagline

@export var item_name := "item_name":
	set(value):
		item_name = value
		$Label.text = value
@export var item_type : ShopItem.ItemTypes = ShopItem.ItemTypes.Infos:
	set(value):
		item_type = value
		if not is_ready:
			await self.ready
		$Icon.texture = ShopItem.ITEM_ICONS[value]
@export_multiline var item_description := ""
@export var item_sprite : Texture

var is_ready := false

func _ready():
	super._ready()
	is_ready = true
