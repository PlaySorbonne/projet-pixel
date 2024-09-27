extends Node

enum ItemTypes {MultGameMode, Map, Minigame, Artwork, Music}

var VAULT_GAMEMODES : Array[VaultItem] = [
	VaultItem.new(
		"Brawl",
		"BRAWL_DESC",
		"",
		null
	),
	VaultItem.new(
		"Shonen Battle",
		"SHONEN_BATTLE_DESC",
		"",
		null
	),
	VaultItem.new(
		"Corporate Chaos",
		"CORPORATE_CHAOS_DESC",
		"",
		null
	),
	VaultItem.new(
		"Otaku Outbreak", 
		"OTAKU_OUTBREAK_DESC", 
		"", 
		load("res://resources/images/objects/anime/anime_one_champsu.png")
	),
	VaultItem.new(
		"Otaku Overdrive",
		"OTAKU_OVERDRIVE_DESC",
		"",
		null
	)
]

var VAULT_MINIGAMES : Array[VaultItem] = [
	VaultItem.new(
		"Training",
		"TRAINING_DESC",
		"",
		null
	),
	VaultItem.new(
		"Stat Editor",
		"STAT_EDITOR_DESC",
		"",
		null
	),
	VaultItem.new(
		"Wild West Shootout",
		"WILD_WEST_DESC",
		"",
		null
	),
	VaultItem.new(
		"Weebocalypse",
		"WEEBOCALYPSE_DESC",
		"",
		null
	),
	VaultItem.new(
		"Retail Relaxation",
		"RETAIL_RELAXATION_DESC",
		"",
		null
	),
	VaultItem.new(
		"Rooster's",
		"ROOSTER_S_DESC",
		"",
		null
	)
]

var VAULT_LEVELS : Array[VaultItem] = [
	VaultItem.new(
		"Wild West Shootout",
		"WILD_WEST_DESC",
		"",
		null
	)
]

var VAULT_ARTWORK : Array[VaultItem] = [
	VaultItem.new(
		"",
		"",
		"",
		null
	)
]

var VAULT_MUSIC : Array[VaultItem] = [
	VaultItem.new(
		"",
		"",
		"",
		null
	)
]



var unlocked_items : Array[String] = []

class VaultItem:
	var item_name := ""
	var item_description := ""
	var item_texture : Texture
	var item_path : String
	
	func _init(_item_name : String, _item_description : String,
	 _item_path : String, _texture : Texture):
		item_name = _item_name
		item_description = _item_description
		item_path = _item_path
		item_texture = _texture
