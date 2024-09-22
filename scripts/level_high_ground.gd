extends Level

@onready var platform = $Path2D/PathFollow2D
@onready var chemin = $Path2D
@onready var timer_pause = $Timer

var speed = 0.4
var direction = 1 
var paused_platform = false

func _ready():
	$AnimeBoxHint.visible = false
	var anime : Node2D
	if GameInfos.game_started:
		anime = ANIME_BOX.instantiate()
		$Music.play(0.0)
	else:
		anime = ANIME_IMPOSTOR.instantiate()
		$Music.queue_free()
	anime.position = $AnimeBoxHint.position
	anime.rotation = $AnimeBoxHint.rotation
	add_child(anime)
	$AnimeBoxHint.queue_free()

func set_music_pitch(new_pitch : float):
	$Music.pitch_scale = new_pitch

func _process(delta):
	if not paused_platform :
		platform.progress_ratio += delta * speed * direction
		if platform.progress_ratio == 1 or platform.progress_ratio == 0:
			paused_platform = true
			timer_pause.start()
			print("reverse")

func _on_timer_timeout():
	direction = -direction
	paused_platform = false
