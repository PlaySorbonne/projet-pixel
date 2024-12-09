extends PlayerCharacter
class_name WeebCharacter

signal weeb_ascended(weeb : WeebCharacter)
signal weeb_descended(weeb : WeebCharacter)

const CHROMATIC_ABERRATION_MAT := preload("res://resources/shaders/chromatic_aberration_material.tres")
const PLAYER_COLOR_MAT := preload("res://resources/shaders/player_color_materialtres.tres")
const AUDIO_EXPLOSION : AudioStream = preload("res://resources/audio/sfx/gameplay_sfx/explosion_egg.wav")
const EXALTED_PARTICLES := preload("res://scenes/Characters/Evolutions/Animations/exalted_weeb_particles.tscn")

@export var ascended_weeb_hitpoints := 3
@export var ascended_scale := Vector2(1.05, 1.05)
@export var ascended_weeb_attack_size := Vector2(2.0, 2.0)

@onready var player_shader_base_col : Color = $Sprite2D.material.get_shader_parameter("base_color")
@onready var ascended_eliminate_on_hit : bool = (
				GameInfos.victory_condition == GameInfos.VictoryConditions.Elimination)
var previous_trail_color : Color
var previous_hitbox_size : Vector2
var exalted_particles : Node2D
var time_ascended := 0.0

func death(force := false):
	if ascended:
		descend()
	else:
		super.death(force)

func get_time_ascended() -> float:
	return time_ascended

func _process(delta: float) -> void:
	if ascended:
		time_ascended += delta

func ascend():
	compute_hits = false
	computing_movement = false
	movement_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	emit_signal("weeb_ascended", self)
	rotation = 0.0
	custom_audio_attacks = AUDIO_EXPLOSION
	controller_vibration(1.0, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "scale", ascended_scale, 0.25)
	await tween.finished
	exalted_particles = EXALTED_PARTICLES.instantiate()
	$Sprite2D.add_child(exalted_particles)
	scale = ascended_scale
	previous_hitbox_size = attack_size
	attack_size = ascended_weeb_attack_size
	$Sprite2D.material = CHROMATIC_ABERRATION_MAT
	$Sprite2D.material.set_shader_parameter("chaos", 60)
	tween = create_tween()
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_green", 
		3.5, 0.2)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_blue", 
		1.25, 0.2)
	$CharacterPointer.set_healthbars_color(Color.CRIMSON)
	max_hitpoints = ascended_weeb_hitpoints
	hitpoints = ascended_weeb_hitpoints
	$CharacterPointer.set_max_hitpoints(ascended_weeb_hitpoints)
	previous_trail_color = $TrailEffect.modulate
	$TrailEffect.modulate = Color.BLACK
	ascended = true
	computing_movement = true
	eliminate_hit_targets = ascended_eliminate_on_hit
	compute_hits = true

func descend():
	emit_signal("weeb_descended", self)
	ascended = false
	scale = default_scale
	custom_audio_attacks = null
	$CharacterPointer.set_healthbars_color(CharacterPointer.DEFAULT_HEALTH_COLOR)
	$CharacterPointer.set_max_hitpoints(0, false)
	GameInfos.anime_box.unfollow_ascended_weeb(
		self, knockback_velocity.rotated(PI / 2.0))
	max_hitpoints = 1
	hitpoints = 0
	if exalted_particles != null:
		exalted_particles.queue_free()
		exalted_particles = null
	attack_size = previous_hitbox_size
	$TrailEffect.modulate = previous_trail_color
	knockback_velocity *= 2.5
	eliminate_hit_targets = false
	$Sprite2D.material = PLAYER_COLOR_MAT
	$Sprite2D.material.set_shader_parameter("base_color", player_shader_base_col)
	super.death()
