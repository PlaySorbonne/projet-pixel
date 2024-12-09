extends Control
class_name PlayerSelection

signal player_removed

const MOUSE_TEXTURE = preload("res://resources/images/icons/mouse.png")
const GAMEPAD_TEXTURE = preload("res://resources/images/icons/gamepad.png")

@export var CEO_lines : Array[AudioStream] = []

var current_ai_difficulty := AI_Inputs.Difficulty.Mid
var right_pressed := false
var left_pressed := false
var up_pressed := false
var down_pressed := false

var with_voice := true
var control_index : int = -1
@export var control_type: bool:
	set(value):
		control_type = value
		ai_difficulty_button.disabled = true
		ai_difficulty_button.visible = false
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

@onready var ai_difficulty_button := $Control/ControlType/ButtonAiDiffculty

func set_player_icon(evolution : int) -> void:
	var new_texture : Texture = PlayerPortrait.PLAYER_PORTRAITS[evolution]
	$Control/Icon.texture = new_texture
	$Control/Icon/Icon2.texture = new_texture

func _ready():
	$Control.scale = Vector2.ZERO
	await get_tree().process_frame
	visible = true
	$AnimationPlayer.play("pop_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	check_winner()
	current_ai_difficulty = GameInfos.players_data[player_index]["ai_difficulty"]
	ai_difficulty_button.text = "\n" + str(AI_Inputs.Difficulty.keys()[current_ai_difficulty])
	if with_voice:
		$AudioCEOVoice.stream = CEO_lines.pick_random()
		$AudioCEOVoice.play()

func set_can_select_evolution(can_select : bool) -> void:
	$Control/EvolutionSelector.visible = can_select

func _input(event : InputEvent):
	var is_correct_control_type = false
	if control_type == false:
		is_correct_control_type = event is InputEventKey
	elif control_type == true:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if not (is_correct_control_type && event.device == control_index):
		return
	if event.is_action_pressed("right") and not right_pressed:
		$Control/Icon/AnimationEmote.play("left")
		right_pressed = true
	elif event.is_action_released("right"):
		right_pressed = false
	if event.is_action_pressed("left") and not left_pressed:
		$Control/Icon/AnimationEmote.play("right")
		left_pressed = true
	elif event.is_action_released("left"):
		left_pressed = false
	if event.is_action_pressed("up") and not up_pressed:
		$Control/Icon/AnimationEmote.play("up")
		up_pressed = true
	elif event.is_action_released("up"):
		up_pressed = false
	if event.is_action_pressed("down") and not down_pressed:
		$Control/Icon/AnimationEmote.play("down")
		down_pressed = true
	elif event.is_action_released("down"):
		down_pressed = false

	if event.is_action_pressed("attack") or event.is_action_pressed(
					"special") or event.is_action_pressed("jump"):
		$Control/Icon/AnimationEmote.play("big")
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.25)
		tween.tween_property(self, "scale", Vector2.ONE, 0.15)

func set_player_evolution(new_evolution : PlayerCharacter.Evolutions) -> void:
	var p : PlayerCharacter = GameInfos.players[player_index]
	p.evolve(new_evolution)
	var new_texture = PlayerPortrait.PLAYER_PORTRAITS[new_evolution]
	$Control/Icon.texture = new_texture
	$Control/Icon/Icon2.texture = new_texture
	await get_tree().process_frame
	$AudioCEOVoice.stream = GameInfos.players[player_index].audio_evolve.pick_random()
	$AudioCEOVoice.play()

func tween_bump(direction : Vector2) -> void:
	pass

func check_winner():
	$Control/LastWinner.visible = last_winner
	if last_winner:
		var tween := create_tween()
		tween.tween_property($Control/LastWinner, "modulate", Color.WHITE, 0.5)
		$Control/LastWinner.declare_winner()

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

func _on_button_ai_diffculty_pressed() -> void:
	match current_ai_difficulty:
		AI_Inputs.Difficulty.Easy:
			current_ai_difficulty = AI_Inputs.Difficulty.Mid
		AI_Inputs.Difficulty.Mid:
			current_ai_difficulty = AI_Inputs.Difficulty.Hard
		AI_Inputs.Difficulty.Hard:
			current_ai_difficulty = AI_Inputs.Difficulty.Easy
	ai_difficulty_button.text = "\n" + str(AI_Inputs.Difficulty.keys()[current_ai_difficulty])
	GameInfos.players_data[player_index]["ai_difficulty"] = current_ai_difficulty
	GameInfos.players[player_index].ai_difficulty = current_ai_difficulty

func _on_evolution_selector_option_changed(option: int) -> void:
	set_player_evolution(option)
	$Control/Icon/AnimationEmote.play("big")
