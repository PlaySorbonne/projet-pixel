extends PlayerCharacter
class_name WeebCharacter

signal weeb_ascended(weeb : WeebCharacter)
signal weeb_descended(weeb : WeebCharacter)

const CHROMATIC_ABERRATION_MAT := preload("res://resources/shaders/chromatic_aberration_material.tres")
const PLAYER_COLOR_MAT := preload("res://resources/shaders/player_color_materialtres.tres")

@export var ascended_weeb_hitpoints := 5

var ascended := false
@onready var player_shader_base_col : Color = $Sprite2D.material.get_shader_parameter("base_color")


func ascend():
	computing_movement = false
	movement_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	emit_signal("weeb_ascended", self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	$Sprite2D.material = CHROMATIC_ABERRATION_MAT
	$Sprite2D.material.set_shader_parameter("chaos", 80)
	ascended = true
	computing_movement = true

func descend():
	emit_signal("weeb_descended", self)
	ascended = false
	scale = default_scale
	knockback_velocity *= 2.5
	$Sprite2D.material = PLAYER_COLOR_MAT
	$Sprite2D.set_shader_parameter("base_color", player_shader_base_col)
