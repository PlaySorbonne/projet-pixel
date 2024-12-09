extends Button
# lives button

var is_lives_forced := false

func _ready() -> void:
	if GameInfos.lives_limit > 0:
		$ButtonCancel.visible = true
		display_lives()
	if GameInfos.victory_condition == GameInfos.VictoryConditions.Kills:
		set_forced_lives(true)

func display_lives() -> void:
	$Label.text = str(GameInfos.lives_limit)

func set_forced_lives(new_forced : bool) -> void:
	is_lives_forced = new_forced
	if is_lives_forced:
		$ButtonCancel.visible = false
		if GameInfos.lives_limit < 0:
			_on_spin_combo_click_up()
	else:
		if GameInfos.lives_limit > 0:
			$ButtonCancel.visible = true

func _on_pressed() -> void:
	if GameInfos.lives_limit < 0:
		_on_spin_combo_click_up()
	else:
		_on_button_cancel_pressed()

func _on_spin_combo_click_down() -> void:
	if GameInfos.lives_limit < 0:
		GameInfos.lives_limit = 5
		if not is_lives_forced:
			$ButtonCancel.visible = true
	else:
		GameInfos.lives_limit = max(GameInfos.lives_limit-1, 1)
	display_lives()

func _on_spin_combo_click_up() -> void:
	if GameInfos.lives_limit < 0:
		GameInfos.lives_limit = 9
		if not is_lives_forced:
			$ButtonCancel.visible = true
	else:
		GameInfos.lives_limit = min(GameInfos.lives_limit+1, 99)
	display_lives()

func _on_button_cancel_pressed() -> void:
	if is_lives_forced:
		return
	$ButtonCancel.visible = false
	GameInfos.lives_limit = -1
	$Label.text = "No_limit"
