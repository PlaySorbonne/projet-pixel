extends Control
class_name PlayerSelection

signal player_removed

const ANIM_NAMES = ["jump", "swell", "swing", "tilt", "rotate", "squash"]
const MOUSE_TEXTURE = preload("res://resources/images/icons/mouse.png")
const GAMEPAD_TEXTURE = preload("res://resources/images/icons/gamepad.png")

@export var CEO_lines : Array[AudioStream] = []


var right_pressed := false
var left_pressed := false
var up_pressed := false
var down_pressed := false

var with_voice := true
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
		set_icons_color(GameInfos.players_data[player_index]["color"])
		$Control/Label.text = GameInfos.players_data[player_index]["name"]
		$PlayerMenuCursor.player_ID = player_index
@export var last_winner := false:
	set(value):
		last_winner = value
		check_winner()

func _ready():
	$Control.scale = Vector2.ZERO
	await get_tree().process_frame
	visible = true
	$AnimationPlayer.play("pop_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	check_winner()
	if with_voice:
		$AudioCEOVoice.stream = CEO_lines.pick_random()
		$AudioCEOVoice.play()

func _input(event : InputEvent):
	var is_correct_control_type = false
	if control_type == false:
		is_correct_control_type = event is InputEventKey
	elif control_type == true:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if not (is_correct_control_type && event.device == control_index):
		return
	if event.is_action_pressed("right") and not right_pressed:
		right_pressed = true
		
	elif event.is_action_released("right"):
		right_pressed = false
	if event.is_action_pressed("left") and not left_pressed:
		left_pressed = true
	elif event.is_action_released("left"):
		left_pressed = false
	if event.is_action_pressed("up") and not up_pressed:
		up_pressed = true
	elif event.is_action_released("up"):
		up_pressed = false
	if event.is_action_pressed("down") and not down_pressed:
		down_pressed = true
	elif event.is_action_released("down"):
		down_pressed = false

	if event.is_action_pressed("attack") or event.is_action_pressed(
					"special") or event.is_action_pressed("jump"):
		$AudioStreamPlayerBoop.play()
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func tween_bump(direction : Vector2) -> void:
	pass

func check_winner():
	$Control/LastWinner.visible = last_winner
	if last_winner:
		var tween := create_tween()
		tween.tween_property($Control/LastWinner, "modulate", Color.WHITE, 0.5)
		_on_animation_player_animation_finished("")

func _on_color_button_pressed() -> void:
	if $Control/ColorPicker.visible:
		$Control/ColorPicker.visible = false
	else:
		$Control/ColorPicker.visible = true
		$Control/ColorPicker.global_position = $Control.global_position + Vector2(
			450, -75)

func _on_color_picker_color_changed(color: Color) -> void:
	GameInfos.players_data[player_index]["color"] = color
	$PlayerMenuCursor.update_color(color)
	set_icons_color(color)

func set_icons_color(color : Color):
	$Control/ColorButton.modulate = color
	$Control/Icon/Icon2.material.set_shader_parameter("color", Vector3(color.r, color.g, color.b))

func _on_label_text_changed(new_text : String) -> void:
	if new_text == GameInfos.players_data[player_index]["name"]:
		return
	GameInfos.players_data[player_index]["name"] = new_text

func _on_animation_player_animation_finished(_anim_name : String):
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
