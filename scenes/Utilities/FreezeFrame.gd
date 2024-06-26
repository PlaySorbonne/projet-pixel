extends Node
class_name FreezeFrame

var added_freeze_frame := 0.0
var in_freeze_frame := false

func _ready():
	GameInfos.freeze_frame = self

func freeze(duration : float = 0.15):
	if in_freeze_frame:
		added_freeze_frame += duration
		return
	in_freeze_frame = true
	var previous_time_scale := Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = previous_time_scale
	in_freeze_frame = false
	if added_freeze_frame > 0.0:
		var new_freeze_frame := added_freeze_frame
		added_freeze_frame = 0.0
		freeze(new_freeze_frame)


