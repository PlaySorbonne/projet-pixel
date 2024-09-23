extends ProgressBar

signal bar_filled

@export var exit_time := 1.25

func _ready():
	max_value = exit_time

func _process(delta : float):
	if Input.is_action_pressed("ui_cancel"):
		visible = true
		value += delta
		if value >= exit_time:
			get_tree().quit()
	else:
		value = 0.0
		visible = false
