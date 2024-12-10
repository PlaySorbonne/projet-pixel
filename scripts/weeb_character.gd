extends PlayerCharacter
class_name WeebCharacter

signal weeb_ascended(weeb : WeebCharacter)
signal weeb_descended(weeb : WeebCharacter)

const CHROMATIC_ABERRATION_MAT := preload("res://resources/shaders/chromatic_aberration_material.tres")
const PLAYER_COLOR_MAT := preload("res://resources/shaders/player_color_materialtres.tres")
const AUDIO_EXPLOSION : AudioStream = preload("res://resources/audio/sfx/gameplay_sfx/explosion_egg.wav")
const EXALTED_PARTICLES := preload("res://scenes/Characters/Evolutions/Animations/exalted_weeb_particles.tscn")

@export var ascended_weeb_hitpoints := 3
@export var ascended_scale := Vector2(0.75, 0.75)    #Vector2(1.05, 1.05)
@export var ascended_weeb_attack_size := Vector2(2.0, 2.0)

@onready var player_shader_base_col : Color = $Sprite2D.material.get_shader_parameter("base_color")
@onready var ascended_eliminate_on_hit : bool = (
				GameInfos.victory_condition == GameInfos.VictoryConditions.Elimination)
var previous_trail_color : Color
var previous_hitbox_size : Vector2
var exalted_particles : Node2D
var time_ascended := 0.0
var dash_speed := 2000.0
var dash_duration := 0.125
var dash_cooldown := 0.25

const GAMEPLAY_PROPERTIES : Dictionary = {
	"max_hitpoints" : 3,
	"speed" : 1.1,
	"attack_size" : 1.5,
	"ascended_scale" : 1.4,
	"jump_velocity" : 1.5,
	"attack_damage" : 3,
	"attack_intensity" : 1.25,
	"knockback_multiplier" : 0.5,
	"attack_recovery" : 0.9,
	"dash_speed" : 1.25,
	"dash_duration" : 1.25,
	"dash_cooldown" : 0.3,
	"air_speed" : 1.1,
	"stun_time" : 1.25,
}
const BOSS_GAMEPLAY_PROPERTIES : Dictionary = {
	"max_hitpoints" : 0,
	"speed" : 0.8,
	"attack_size" : 1.75,
	"ascended_scale" : 2.5,
	"jump_velocity" : 1.75,
	"attack_damage" : 2.75,
	"attack_intensity" : 1.75,
	"knockback_multiplier" : 0.2,
	"attack_recovery" : 0.25,
	"dash_speed" : 1.2,
	"dash_duration" : 1.1,
	"dash_cooldown" : 0.3,
	"air_speed" : 0.8,
	"stun_time" : 0.0,
}
var default_stats : Dictionary = {}
var ascended_stats : Dictionary = {}

func _ready() -> void:
	super._ready()
	await get_tree().process_frame
	set_ascended_stats(GameInfos.victory_condition == GameInfos.VictoryConditions.KillBoss)

func set_ascended_stats(is_boss_weeb := false) -> void:
	default_stats = {}
	ascended_stats = {}
	for s : String in GAMEPLAY_PROPERTIES.keys():
		default_stats[s] = self.get(s)
		if is_boss_weeb:
			ascended_stats[s] = self.get(s) * BOSS_GAMEPLAY_PROPERTIES[s]
		else:
			ascended_stats[s] = self.get(s) * GAMEPLAY_PROPERTIES[s]
	if is_boss_weeb:
		ascended_stats["max_hitpoints"] = 20 * int( (5 * GameInfos.lives_limit) / 9 )
		#ascended_stats["attack_damage"] = 5

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
	
	for s : String in GAMEPLAY_PROPERTIES.keys():
		self.set(s, ascended_stats[s])
	hitpoints = max_hitpoints
	$SpecialAttack.dash_speed    = dash_speed
	$SpecialAttack.dash_duration = dash_duration
	$SpecialAttack.dash_cooldown = dash_cooldown
	
	var tween := create_tween()
	tween.tween_property(self, "scale", ascended_scale, 0.25)
	await tween.finished
	scale = ascended_scale
	
	exalted_particles = EXALTED_PARTICLES.instantiate()
	$Sprite2D.add_child(exalted_particles)
	$Sprite2D.material = CHROMATIC_ABERRATION_MAT
	$Sprite2D.material.set_shader_parameter("chaos", 60)
	tween = create_tween()
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_green", 
		3.5, 0.2)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_blue", 
		1.25, 0.2)
	$CharacterPointer.set_healthbars_color(Color.CRIMSON)
	$CharacterPointer.set_max_hitpoints(max_hitpoints)
	previous_trail_color = $TrailEffect.modulate
	$TrailEffect.modulate = Color.BLACK
	ascended = true
	computing_movement = true
	eliminate_hit_targets = ascended_eliminate_on_hit
	compute_hits = true

func descend():
	emit_signal("weeb_descended", self)
	ascended = false
	
	for s : String in GAMEPLAY_PROPERTIES.keys():
		self.set(s, default_stats[s])
	$SpecialAttack.dash_speed    = dash_speed
	$SpecialAttack.dash_duration = dash_duration
	$SpecialAttack.dash_cooldown = dash_cooldown
	
	scale = default_scale
	custom_audio_attacks = null
	$CharacterPointer.set_healthbars_color(CharacterPointer.DEFAULT_HEALTH_COLOR)
	$CharacterPointer.set_max_hitpoints(0, false)
	GameInfos.anime_box.unfollow_ascended_weeb(
		self, knockback_velocity.rotated(PI / 2.0))
	hitpoints = 0
	if exalted_particles != null:
		exalted_particles.queue_free()
		exalted_particles = null
	$TrailEffect.modulate = previous_trail_color
	knockback_velocity *= 2.5
	eliminate_hit_targets = false
	$Sprite2D.material = PLAYER_COLOR_MAT
	$Sprite2D.material.set_shader_parameter("base_color", player_shader_base_col)
	super.death()
