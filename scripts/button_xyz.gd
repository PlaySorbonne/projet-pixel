extends BaseButton
class_name ButtonXYZ

@export var audio : AudioStream
@export var volume_db := 0.0

var audio_stream_player : AudioStreamPlayer

func _ready():
	self.connect("pressed", play_sound)
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)

func play_sound():
	audio_stream_player.stop()
	audio_stream_player.volume_db = volume_db
	audio_stream_player.stream = audio
	audio_stream_player.play(0.0)
