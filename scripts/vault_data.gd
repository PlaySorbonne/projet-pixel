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
		"INITIAL_ARTWORK",
		"INITIAL_ARTWORK_DESC",
		"res://resources/images/artworks/initial_artworks.tscn",
		null
	),
	VaultItem.new(
		"OCEAN_ARTWORK",
		"OCEAN_ARTWORK_DESC",
		"res://resources/images/artworks/ocean_artworks.tscn",
		null
	),
	VaultItem.new(
		"CEO_TO_WEEB_ARTWORK",
		"CEO_TO_WEEB_ARTWORK_DESC",
		"res://resources/images/artworks/ceo_to_weeb_artworks.tscn",
		null
	)
]

var VAULT_MUSIC : Array[VaultItem] = [
	VaultItem.new(
		"VOICE_OVER_SHITPOST",
		"VOICE_OVER_SHITPOST_DESC",
		"res://resources/audio/voice_over_shitpost.tscn",
		null
	)
]

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

const VAULT_FILE_NAME := "user://ascend_settings.txt"

var vault_data : Dictionary = {
	"money" : 0,
	"unlocked_items" : []
}

func load_vault_data():
	if not FileAccess.file_exists(VAULT_FILE_NAME):
		# no settings file exist on this computer
		return 
	var save_file := FileAccess.open(VAULT_FILE_NAME, FileAccess.READ)
	var json_string := save_file.get_line()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if not parse_result == OK:
		print("JSON parse error in loading settings file")
		return
	vault_data = json.get_data()
	save_file.close()

func save_vault_data():
	var save_file := FileAccess.open(VAULT_FILE_NAME, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(vault_data))
	save_file.close()
