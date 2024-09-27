extends VaultSubScreen

const SHOP_ITEM_PATH := preload("res://scenes/Menus/Vault/shop_item.tscn")

@export var shop_items : Dictionary = {
	
}

func _ready():
	pass

func add_shop_items() -> ShopItem:
	var first_itme : ShopItem = null
	for s : String in shop_items.keys():
		var item : ShopItem = SHOP_ITEM_PATH.instantiate()
		item.item_name = s
		item.item_type
		item.price = shop_items[s]
		item.item_description
		if first_itme == null:
			first_itme = item
		$ScrollContainer/VBoxItems.add_child(item)
	$ScrollContainer.ensure_children_focus()
	return first_itme
