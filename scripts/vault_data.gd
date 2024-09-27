extends Node

enum ItemTypes {MultGameMode, Map, Minigame, Artwork, Music}

var VAULT_ITEMS : Array[VaultItem] = [
	VaultItem.new(
		"Otaku Outbreak", 
		"desc", 
		ItemTypes.MultGameMode, 
		"", 
		load("res://resources/images/objects/anime/anime_one_champsu.png")
	),
	VaultItem.new(
		"Otaku Overdrive",
		"desc",
		ItemTypes.MultGameMode,
		"",
		null
	),
	VaultItem.new(
		"",
		"",
		ItemTypes.Map,
		"",
		null
	)
]
var unlocked_items : Array[String] = []

class VaultItem:
	var item_name := ""
	var item_description := ""
	var item_type : ItemTypes
	var item_texture : Texture
	var item_path : String
	
	func _init(_item_name : String, _item_description : String,
	 _item_type : ItemTypes, _item_path : String, _texture : Texture):
		item_name = _item_name
		item_description = _item_description
		item_type = _item_type
		item_path = _item_path
		item_texture = _texture
