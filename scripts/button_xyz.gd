extends Button
class_name ButtonXYZ

@export var audio : AudioStream
var audio_stream_player : AudioStreamPlayer

func _ready():
	self.connect("pressed", play_sound)
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = audio

func set_audio(new_audio : AudioStream):
	audio = new_audio

func play_sound():
	pass
