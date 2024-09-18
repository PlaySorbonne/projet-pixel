extends Control
class_name PlayerSelection

signal player_removed

const MOUSE_TEXTURE = preload("res://resources/images/icons/mouse.png")
const GAMEPAD_TEXTURE = preload("res://resources/images/icons/gamepad.png")

var default_player_name := ""
var control_index : int = -1
@export var control_type: bool:
	set(value):
		control_type = value
		if value:
			$Control/ControlType.texture = GAMEPAD_TEXTURE
		else:
			$Control/ControlType.texture = MOUSE_TEXTURE
@export var player_index: int:
	set(value):
		player_index = value
		set_icons_color(GameInfos.player_colors[player_index])
		$Control/Label.text = GameInfos.player_names[player_index]
@export var last_winner := false:
	set(value):
		last_winner = value
		$Control/LastWinner.visible = last_winner
		if last_winner:
			_on_animation_player_animation_finished("")

func _ready():
	$AnimationPlayer.play("pop_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")

func _on_color_button_pressed() -> void:
	$Control/ColorPicker.visible = !$Control/ColorPicker.visible

func _on_color_picker_color_changed(color: Color) -> void:
	#$Control/ColorPicker.visible = false
	GameInfos.player_colors[player_index] = color
	set_icons_color(color)

func set_icons_color(color : Color):
	$Control/ColorButton.modulate = color
	$Control/Icon/Icon2.material.set_shader_parameter("color", Vector3(color.r, color.g, color.b))

func _on_label_text_changed(new_text : String) -> void:
	if new_text == GameInfos.player_names[player_index]:
		return
	if new_text == "" or new_text in GameInfos.player_names:
		$Control/Label.text = ""
		return
	GameInfos.player_names[player_index] = new_text

func _on_animation_player_animation_finished(anim_name : String):
	const ANIM_NAMES = ["jump", "swell", "swing", "tilt"]
	var win_player : AnimationPlayer = $Control/LastWinner/texture/AnimationPlayer
	win_player.play(ANIM_NAMES.pick_random())

func _on_button_cancel_pressed():
	emit_signal("player_removed", self, player_index)
	$Control/Label.editable = false
	$Control/ColorButton.disabled = true
	$Control/ButtonCancel.disabled = true
	$AnimationPlayer.play("pop_out")
	await $AnimationPlayer.animation_finished
	GameInfos.remove_player(player_index)
	queue_free()

func _on_label_text_submitted(_new_text : String):
	$Control/Label.release_focus()
