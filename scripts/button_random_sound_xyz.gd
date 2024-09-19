@tool
extends XYZ_Button
class_name XYZ_ButtonRandomSound

static var global_sound_array : Array[AudioStream] = []

@export var sound_array : Array[AudioStream] = []
@export var save_as_global_array := false:
	set(value):
		global_sound_array = sound_array
@export var load_global_sound_array := false:
	set(value):
		sound_array = global_sound_array

func play_sound():
	audio = sound_array.pick_random()
	super.play_sound()
