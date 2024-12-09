extends Button
# TimeButton

var is_time_forced := false

func _ready() -> void:
	if GameInfos.time_limit > 0:
		display_time_as_text()
		$ButtonCancel.visible = true
	if GameInfos.victory_condition == GameInfos.VictoryConditions.CassetteTime:
		is_time_forced = true

func _on_pressed() -> void:
	if GameInfos.time_limit < 0:
		_on_spin_combo_click_up()
	else:
		_on_button_cancel_pressed()

func display_time_as_text() -> void:
	var minutes := int(GameInfos.time_limit/60)
	$Label.text = str(minutes) + ":" + str(GameInfos.time_limit % 60).pad_zeros(2)

func _on_spin_combo_click_down() -> void:
	if GameInfos.time_limit < 0:
		GameInfos.time_limit = 60
		$ButtonCancel.visible = true
	else:
		GameInfos.time_limit = max(30, GameInfos.time_limit-30)
	display_time_as_text()

func set_forced_time(timed : bool) -> void:
	is_time_forced = timed
	if is_time_forced:
		$ButtonCancel.visible = false
		if GameInfos.time_limit < 0:
			_on_spin_combo_click_up()
	else:
		if GameInfos.time_limit > 0:
			$ButtonCancel.visible = true

func _on_spin_combo_click_up() -> void:
	if GameInfos.time_limit < 0:
		GameInfos.time_limit = 120
		if not is_time_forced:
			$ButtonCancel.visible = true
	else:
		GameInfos.time_limit = min(600, GameInfos.time_limit+30)
	display_time_as_text()

func _on_button_cancel_pressed() -> void:
	if is_time_forced:
		return
	GameInfos.time_limit = -1
	$ButtonCancel.visible = false
	$Label.text = "No_limit"
