extends Control

const MOUSE_TEXTURE = preload("res://resources/images/icons/mouse.png")
const GAMEPAD_TEXTURE = preload("res://resources/images/icons/gamepad.png")

@export var player_index: int

func _ready() -> void:
	$ColorButton.modulate = GameInfos.player_colors[player_index]
	#$ControlType.texture = MOUSE_TEXTURE if (GameInfos.players[player_index].control_type == 0) else GAMEPAD_TEXTURE

func _on_button_pressed() -> void:
	$ColorPicker.visible = !$ColorPicker.visible

func _on_color_picker_color_changed(color: Color) -> void:
	GameInfos.player_colors[player_index] = color
	$ColorButton.modulate = color
