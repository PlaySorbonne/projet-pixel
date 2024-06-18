extends Node
class_name FreezeFrame

var in_freeze_frame := false

func _ready():
	GameInfos.freeze_frame = self

func freeze(duration : float = 0.15):
	if in_freeze_frame:
		return
	in_freeze_frame = true
	var previous_time_scale := Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = previous_time_scale
	in_freeze_frame = false


