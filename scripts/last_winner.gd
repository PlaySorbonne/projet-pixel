extends Control

const ANIM_NAMES = ["jump", "swell", "swing", "tilt", "rotate", "squash"]

func declare_winner():
	modulate = Color.WHITE
	_on_animation_player_animation_finished("")

func _on_animation_player_animation_finished(_anim_name : String):
	$texture/AnimationPlayer.play(ANIM_NAMES.pick_random())
