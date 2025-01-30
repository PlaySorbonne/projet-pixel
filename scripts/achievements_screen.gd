extends Control


var TITLE_ITEM = PlayerVictoryStats.TITLE_ITEM
var remaining_titles : Array[String] = []

func _ready() -> void:
	remaining_titles = VaultData.vault_data["unlocked_titles"].duplicate()
	remaining_titles.shuffle()
	$TimerSpawnTitle.start(randf_range(0.5, 0.75))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_spawn_title_timeout() -> void:
	var title_str : String = remaining_titles.pop_back()
	var val : TitleItem.Rarities
	if title_str in EndScreen.LEGENDARY_TITLES:
		val = TitleItem.Rarities.Legendary
	elif title_str in EndScreen.RARE_TITLES:
		val = TitleItem.Rarities.Rare
	else:
		val = TitleItem.Rarities.Common
	var title_obj : TitleItem = TITLE_ITEM.instantiate()
	title_obj.set_title(title_str, val)
	$Titles.add_child(title_obj)
	if remaining_titles.size() == 0:
		return
	$TimerSpawnTitle.start(randf_range(0.1, 0.3))
	
