extends SubScreen


var TITLE_ITEM = PlayerVictoryStats.TITLE_ITEM
var remaining_titles : Array = []
var is_currently_focused := false

func _ready() -> void:
	super._ready()
	if "unlocked_titles" in VaultData.vault_data.keys():
		remaining_titles = VaultData.vault_data["unlocked_titles"].duplicate()
		remaining_titles.shuffle()


func _on_timer_spawn_title_timeout() -> void:
	if remaining_titles.size() == 0:
		return
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
	title_obj.anim_intro(false)
	title_obj.scale = Vector2.ONE * 1.5
	title_obj.position = Vector2(
		randf_range($Titles/TopLeft.position.x, $Titles/DownRight.position.x),
		randf_range($Titles/TopLeft.position.y, $Titles/DownRight.position.y)
	)
	if remaining_titles.size() == 0:
		return
	$TimerSpawnTitle.start(randf_range(0.025, 0.15))

func shake_screen() -> void:
	if not is_currently_focused:
		return
	$Shaker.shake(0.2, 20, 40)

func _on_button_back_pressed() -> void:
	$ButtonBack.release_focus()
	is_currently_focused = false
	emit_signal("ButtonBackPressed")

func _on_screen_focused() -> void:
	$TimerSpawnTitle.start(1.75)
	is_currently_focused = true
