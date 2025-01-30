extends BaseButton
class_name XYZ_Button

@export var audio : AudioStream
@export var volume_db := 0.0

var audio_stream_player : AudioStreamPlayer
var is_gamepad_clickable := false

func _ready():
	self.connect("pressed", play_sound)
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)

func play_sound():
	is_gamepad_clickable = false
	audio_stream_player.stop()
	audio_stream_player.volume_db = volume_db
	audio_stream_player.stream = audio
	audio_stream_player.play(0.0)

func set_gamepad_clickable() -> void:
	is_gamepad_clickable = true

func _process(delta: float) -> void:
	if not is_gamepad_clickable:
		return
	if Input.is_action_just_pressed("special"):
		emit_signal("pressed")
