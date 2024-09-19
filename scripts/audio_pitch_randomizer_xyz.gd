extends AudioStreamPlayer
class_name XYZ_AudioPitchRandomizer

@export var pitch_min := 0.9
@export var pitch_max := 1.1

func play_random_pitch(from := 0.0):
	pitch_scale = randf_range(pitch_min, pitch_max)
	play(from)
