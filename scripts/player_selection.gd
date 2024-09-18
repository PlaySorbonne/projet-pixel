extends Control
class_name PlayerSelection

const MOUSE_TEXTURE = preload("res://resources/images/icons/mouse.png")
const GAMEPAD_TEXTURE = preload("res://resources/images/icons/gamepad.png")

@export var control_type: bool:
	set(value):
		control_type = value
		if value:
			$ControlType.texture = MOUSE_TEXTURE
		else:
			$ControlType.texture = GAMEPAD_TEXTURE
@export var player_index: int:
	set(value):
		$ColorButton.modulate = GameInfos.player_colors[player_index]
		$Label.text = GameInfos.player_names[player_index]
		player_index = value
@export var last_winner := false:
	set(value):
		$LastWinner.visible = last_winner
		if last_winner:
			_on_animation_player_animation_finished("")


func _on_button_pressed() -> void:
	$ColorPicker.visible = !$ColorPicker.visible

func _on_color_picker_color_changed(color: Color) -> void:
	GameInfos.player_colors[player_index] = color
	$ColorButton.modulate = color

func _on_label_text_changed(new_text : String) -> void:
	if new_text == GameInfos.player_names[player_index]:
		return
	if new_text == "" or new_text in GameInfos.player_names:
		$Label.text = ""
		return
	GameInfos.player_names[player_index] = new_text

func _on_animation_player_animation_finished(anim_name : String):
	const ANIM_NAMES = ["jump", "swell", "swing", "tilt"]
	var win_player : AnimationPlayer = $LastWinner/texture/AnimationPlayer
	win_player.play(ANIM_NAMES.pick_random())

func _on_button_cancel_pressed():
	GameInfos.players[player_index].remove_player()
