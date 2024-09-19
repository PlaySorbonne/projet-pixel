extends AnimatedSprite2D

var both_finished := false

func _ready():
	play("default")
	$AudioExplosion.play_random_pitch()

func _on_animation_finished():
	finish()

func _on_audio_explosion_finished():
	finish()

func finish():
	if both_finished:
		queue_free()
	else:
		both_finished = true
