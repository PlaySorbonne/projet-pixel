extends Label
class_name GameplayTimer

signal timeout

var current_time : float = 15

func _ready() -> void:
	text = ""
	$Label.text = ""
	set_process(false)

func start_timer(new_time : float) -> void:
	current_time = new_time
	set_process(true)

func _process(delta: float) -> void:
	current_time -= delta
	var current_time_secs : int = int(current_time)
	var current_minutes : int = current_time_secs / 60
	if current_time <= 0:
		set_process(false)
		current_time = 0.0
		emit_signal("timeout")
	text = str(current_minutes) + ":" + str(current_time_secs % 60).pad_zeros(2)
	$Label.text = "." + str((current_time-current_time_secs)*100).pad_zeros(2)
