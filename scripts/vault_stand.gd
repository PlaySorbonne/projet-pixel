extends Control
class_name VaultSubScreen

const VAULT_TO_SHOP_TYPE : Dictionary = {
	VaultData.ItemTypes.MultGameMode : ShopItem.ItemTypes.GameMode,
	VaultData.ItemTypes.Map : ShopItem.ItemTypes.Level, 
	VaultData.ItemTypes.Minigame : ShopItem.ItemTypes.Minigame, 
	VaultData.ItemTypes.Artwork : ShopItem.ItemTypes.Art, 
	VaultData.ItemTypes.Music : ShopItem.ItemTypes.Music 
}

@export var grab_control_node : Control
