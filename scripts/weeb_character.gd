extends PlayerCharacter
class_name WeebCharacter

signal weeb_ascended(weeb : WeebCharacter)
signal weeb_descended(weeb : WeebCharacter)

const CHROMATIC_ABERRATION_MAT := preload("res://resources/shaders/chromatic_aberration_material.tres")
const PLAYER_COLOR_MAT := preload("res://resources/shaders/player_color_materialtres.tres")

@export var ascended_weeb_hitpoints := 15
@export var ascended_scale := Vector2(1.1, 1.1)
@export var ascended_weeb_attack_size := Vector2(2.0, 2.0)

@onready var player_shader_base_col : Color = $Sprite2D.material.get_shader_parameter("base_color")
var ascended := false
var previous_trail_color : Color
var previous_hitbox_size : Vector2

func death(force := false):
	if ascended:
		descend()
	else:
		super.death(force)

func ascend():
	computing_movement = false
	movement_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	emit_signal("weeb_ascended", self)
	rotation = 0.0
	var tween := create_tween()
	tween.tween_property(self, "scale", ascended_scale, 0.25)
	await tween.finished
	scale = ascended_scale
	previous_hitbox_size = attack_size
	attack_size = ascended_weeb_attack_size
	$Sprite2D.material = CHROMATIC_ABERRATION_MAT
	$Sprite2D.material.set_shader_parameter("chaos", 60)
	$CharacterPointer.set_healthbars_color(Color.AQUA)
	max_hitpoints = ascended_weeb_hitpoints
	hitpoints = ascended_weeb_hitpoints
	$CharacterPointer.set_max_hitpoints(ascended_weeb_hitpoints)
	previous_trail_color = $TrailEffect.modulate
	$TrailEffect.modulate = Color.BLACK
	ascended = true
	computing_movement = true
	eliminate_hit_targets = true

func descend():
	emit_signal("weeb_descended", self)
	ascended = false
	scale = default_scale
	$CharacterPointer.set_healthbars_color(CharacterPointer.DEFAULT_HEALTH_COLOR)
	$CharacterPointer.set_max_hitpoints(1, false)
	GameInfos.anime_box.unfollow_ascended_weeb(
		self, knockback_velocity.rotated(PI / 2.0))
	max_hitpoints = 1
	hitpoints = 1
	attack_size = previous_hitbox_size
	$TrailEffect.modulate = previous_trail_color
	knockback_velocity *= 2.5
	eliminate_hit_targets = false
	$Sprite2D.material = PLAYER_COLOR_MAT
	$Sprite2D.material.set_shader_parameter("base_color", player_shader_base_col)
