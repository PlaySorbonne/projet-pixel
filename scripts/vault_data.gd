extends Node

enum ItemTypes {MultGameMode, Map, Minigame, Artwork, Music}

var vault_gamemodes : Array[VaultItem] = [
	VaultItem.new(
		"Brawl",
		"BRAWL_DESC",
		"",
		null,
		ItemTypes.MultGameMode
	),
	VaultItem.new(
		"Shonen Battle",
		"SHONEN_BATTLE_DESC",
		"",
		null,
		ItemTypes.MultGameMode
	),
	VaultItem.new(
		"Corporate Chaos",
		"CORPORATE_CHAOS_DESC",
		"",
		null,
		ItemTypes.MultGameMode
	),
	VaultItem.new(
		"Otaku Outbreak", 
		"OTAKU_OUTBREAK_DESC", 
		"", 
		load("res://resources/images/objects/anime/anime_one_champsu.png"),
		ItemTypes.MultGameMode
	),
	VaultItem.new(
		"Otaku Overdrive",
		"OTAKU_OVERDRIVE_DESC",
		"",
		null,
		ItemTypes.MultGameMode
	)
]

var vault_minigames : Array[VaultItem] = [
	VaultItem.new(
		"Training",
		"TRAINING_DESC",
		"",
		null,
		ItemTypes.Minigame
	),
	VaultItem.new(
		"Stat Editor",
		"STAT_EDITOR_DESC",
		"",
		null,
		ItemTypes.Minigame
	),
	VaultItem.new(
		"Wild West Shootout",
		"WILD_WEST_DESC",
		"",
		null,
		ItemTypes.Minigame
	),
	VaultItem.new(
		"Weebocalypse",
		"WEEBOCALYPSE_DESC",
		"",
		null,
		ItemTypes.Minigame
	),
	VaultItem.new(
		"Retail Relaxation",
		"RETAIL_RELAXATION_DESC",
		"",
		null,
		ItemTypes.Minigame
	),
	VaultItem.new(
		"Rooster's",
		"ROOSTER_S_DESC",
		"",
		null,
		ItemTypes.Minigame
	)
]

var vault_levels : Array[VaultItem] = [
	VaultItem.new(
		"High Ground",
		"HIGH_GROUND_DESC",
		"res://scenes/World/Levels/level_high_ground.tscn",
		null,
		ItemTypes.Map,
		800
	)
]

var vault_artwork : Array[VaultItem] = [
	VaultItem.new(
		"INITIAL_ARTWORK",
		"INITIAL_ARTWORK_DESC",
		"res://resources/images/artworks/initial_artworks.tscn",
		null,
		ItemTypes.Artwork,
		400
	),
	VaultItem.new(
		"OCEAN_ARTWORK",
		"OCEAN_ARTWORK_DESC",
		"res://resources/images/artworks/ocean_artworks.tscn",
		null,
		ItemTypes.Artwork,
		400
	),
	VaultItem.new(
		"CEO_TO_WEEB_ARTWORK",
		"CEO_TO_WEEB_ARTWORK_DESC",
		"res://resources/images/artworks/ceo_to_weeb_artworks.tscn",
		null,
		ItemTypes.Artwork,
		600
	)
]

var vault_music : Array[VaultItem] = [
	VaultItem.new(
		"VOICE_OVER_SHITPOST",
		"VOICE_OVER_SHITPOST_DESC",
		"res://resources/audio/voice_over_shitpost.tscn",
		null,
		ItemTypes.Music,
		750
	)
]

class VaultItem:
	var item_name := ""
	var item_description := ""
	var item_texture : Texture
	var item_path : String
	var item_type : ItemTypes
	var item_price : int
	
	func _init(_item_name : String, _item_description : String, _item_path : String, 
	_texture : Texture, _type : ItemTypes, _price : int = 500):
		item_name = _item_name
		item_description = _item_description
		item_path = _item_path
		item_texture = _texture
		item_type = _type
		item_price = _price

const VAULT_FILE_NAME := "user://ascend_vault_data.txt"

var vault_data : Dictionary = {
	"money" : 0,
	"unlocked_items" : ["CEO_TO_WEEB_ARTWORK"]
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
		print("JSON parse error in loading vault data file")
		return
	vault_data = json.get_data()
	save_file.close()
	print("vault data = " + str(vault_data))

func save_vault_data():
	var save_file := FileAccess.open(VAULT_FILE_NAME, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(vault_data))
	save_file.close()
