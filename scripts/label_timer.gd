extends Label
class_name GameplayTimer

signal timeout

var current_time : float = 0

func _ready() -> void:
	GameInfos.gameplay_timer = self
	if GameInfos.time_limit < 0:
		text = ""
		$Label.text = ""
	else:
		current_time = GameInfos.time_limit
		display_time_as_text()
	set_process(false)
	await get_tree().process_frame
	GameInfos.world.connect("game_finished", stop_timer)

func start_timer() -> void:
	set_process(true)

func stop_timer() -> void:
	set_process(false)

func _process(delta: float) -> void:
	current_time -= delta
	if current_time <= 0:
		set_process(false)
		current_time = 0.0
		emit_signal("timeout")
	display_time_as_text()

func display_time_as_text() -> void: 
	var current_time_secs : int = int(current_time)
	var current_minutes : int = current_time_secs / 60
	text = str(current_minutes) + ":" + str(current_time_secs % 60).pad_zeros(2)
	$Label.text = "." + str((current_time-current_time_secs)*100).pad_zeros(2)
