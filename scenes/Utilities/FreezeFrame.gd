extends Node
class_name FreezeFrame



func freeze(duration : float = 0.15):
	var previous_time_scale := Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = previous_time_scale


