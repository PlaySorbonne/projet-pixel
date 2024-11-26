extends Control

const ANIM_NAMES = ["jump", "swell", "swing", "tilt", "rotate", "squash"]

func declare_winner():
	_on_animation_player_animation_finished("")

func _on_animation_player_animation_finished(_anim_name : String):
	var win_player : AnimationPlayer = $Control/LastWinner/texture/AnimationPlayer
	win_player.play(ANIM_NAMES.pick_random())
