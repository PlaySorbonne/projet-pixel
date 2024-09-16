extends Node
class_name FreezeFrame

signal freeze_frame_ended

var added_freeze_frame := 0.0
var in_freeze_frame := false
var default_time_scale := 1.0

func _ready():
	GameInfos.freeze_frame = self
	Engine.time_scale = 1.0

func freeze(duration : float = 0.075):
	if in_freeze_frame:
		added_freeze_frame += duration
		return
	in_freeze_frame = true
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = default_time_scale
	in_freeze_frame = false
	emit_signal("freeze_frame_ended")
	if added_freeze_frame > 0.0:
		var new_freeze_frame := added_freeze_frame
		added_freeze_frame = 0.0
		freeze(new_freeze_frame)

func slow_mo(time_scale : float, duration : float):
	if in_freeze_frame:
		await self.freeze_frame_ended
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = default_time_scale

func set_time_scale(time_scale : float):
	Engine.time_scale = time_scale
	default_time_scale = time_scale
	#var tween := create_tween()
	#tween.tween_property(self, "_time_scale_val", time_scale, duration)
