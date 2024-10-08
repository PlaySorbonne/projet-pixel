extends VaultSubScreen

const SHOP_ITEM_PATH := preload("res://scenes/Menus/Vault/shop_item.tscn")
var shop_items : Array[VaultData.VaultItem] = []

func _ready():
	var first_item : Control = add_shop_items()
	grab_control_node = first_item

func add_shop_items() -> ShopItem:
	shop_items = []
	for item : VaultData.VaultItem in (VaultData.vault_gamemodes + VaultData.vault_levels + (
		VaultData.vault_minigames + VaultData.vault_artwork + VaultData.vault_music)):
			if not (item.item_name in VaultData.vault_data["unlocked_items"]):
				shop_items.append(item)
	var first_itme : ShopItem = null
	for s : VaultData.VaultItem in shop_items:
		var item : ShopItem = SHOP_ITEM_PATH.instantiate()
		item.item_name = s.item_name
		item.item_type = VAULT_TO_SHOP_TYPE[s.item_type]
		item.price = s.item_price
		item.item_description = s.item_description
		if first_itme == null:
			first_itme = item
		$ScrollContainer/VBoxItems.add_child(item)
	$ScrollContainer.ensure_children_focus()
	return first_itme
