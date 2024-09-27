@tool
extends XYZ_ClickableHBox
class_name ShopItem

enum ItemTypes {GameMode, Minigame, Level, Art, Music, StatEditor, Character, Lore, Infos}

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
		"res://resources/images/interface/vault_items_icons/flask_half.png"),
	ItemTypes.Character : preload(
		"res://resources/images/interface/vault_items_icons/singleplayer.png"),
	ItemTypes.Lore : preload(
		"res://resources/images/interface/vault_items_icons/book_open.png"),
	ItemTypes.Infos : preload(
		"res://resources/images/interface/vault_items_icons/question.png")
}

const BROKE_AUDIO := preload("res://resources/audio/voices/poulet/shop_broke.wav")
const MONEY_AUDIO := preload("res://resources/audio/voices/poulet/shop_money.wav")

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
@export_multiline var item_description := ""
var item_bought := false

func _on_pressed():
	if item_bought:
		return
	buy_item()

func buy_item():
	if VaultData.vault_data["money"] >= price:
		item_bought = true
		VaultData.vault_data["money"] -= price
		VaultData.vault_data["unlocked_items"].append(item_name)
		VaultData.save_vault_data()
		$Audio.stream = MONEY_AUDIO
		$Audio.play()
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		$Audio.stream = BROKE_AUDIO
		$Audio.play()
