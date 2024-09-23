extends RigidBody2D
class_name AnimeBox

signal game_won
signal hentai_hit

const WEEB_TOUCHED_SHADER_VALS = {
	"chaos" : [15.0, 30.0, 70.0],
	"blue"  : [0.75, 0.5, 0.25],
	"hit"   : [1.0, 1.5, 2.5]
}
const BOUNDS = 3000
const LIMIT_SPEED_DAMAGE_DOWN = pow(250, 2.0)
const DAMAGING_TIME_MIN = 0.25
const OBJECTIVE_BOX_RES = preload("res://scenes/World/Objects/ObjectiveBox.tscn")

@export var anime_velocity := 2000.0
@export var anime_damage_multiplier := 1.0
@export var winning_by_weeb_touch := true
@export var max_hitpoints := 5

@onready var trail_effect := $TrailEffect
@onready var character_pointer : CharacterPointer = $CharacterPointer
var team := -1
var last_player_hit : PlayerCharacter = null
var last_hit_value := 0
var damaging := true
var damaging_timer := 0.0
var chaos_value_at_rest := 0.0
var blue_div_at_rest := 1.0
var weeb_touched : int = 0
var last_valid_pos : Vector2

func shuffle_off_this_mortal_coil_cuz_physics_suck_and_the_world_is_a_broken_simulation():
	var new_body := OBJECTIVE_BOX_RES.instantiate()
	new_body.freeze = true
	new_body.weeb_touched = weeb_touched
	new_body.set_hitpoints(max_hitpoints-weeb_touched, false)
	new_body.damaging = damaging
	new_body.chaos_value_at_rest = chaos_value_at_rest
	new_body.blue_div_at_rest = blue_div_at_rest
	new_body.position = last_valid_pos
	#new_body.last_hit_value = last_hit_value
	#new_body.last_player_hit = last_player_hit
	new_body.damaging_timer = damaging_timer
	if damaging:
		new_body.set_tape_hit_mode()
	else:
		new_body.set_tape_rest_mode()
	GameInfos.world.level.add_child(new_body)
	GameInfos.tracked_targets.erase(self)
	await get_tree().create_timer(0.05).timeout
	new_body.freeze = false
	queue_free()

func _process(delta : float):
	if not (position.x < BOUNDS and position.x > -BOUNDS and position.y < BOUNDS and position.y > -BOUNDS):
		set_process(false)
		shuffle_off_this_mortal_coil_cuz_physics_suck_and_the_world_is_a_broken_simulation()
	else:
		last_valid_pos = position
	if damaging_timer > 0.0:
		damaging_timer -= delta
	elif damaging and linear_velocity.length_squared() < LIMIT_SPEED_DAMAGE_DOWN:
		set_tape_rest_mode()

func _ready():
	GameInfos.anime_box = self
	if GameInfos.game_started:
		await get_tree().create_timer(0.1).timeout
		connect("game_won", GameInfos.world.end_game)
		GameInfos.world.connect("weeb_arrived", set_hitpoints)
		GameInfos.tracked_targets.append(self)
	else:
		set_process(false)
	#physics_material_override.bounce = 1.0 # maybe put bounciness, etc as parameters

func set_hitpoints(hitpoints := max_hitpoints, with_anim := true):
	$CharacterPointer.set_max_hitpoints(hitpoints, with_anim)

func increment_weeb_touched():
	$AudioWeebTouched.pitch_scale = 1.5 - weeb_touched/4.0
	$AudioWeebTouched.play(0.0)
	var array_index : int = min(
		weeb_touched, len(WEEB_TOUCHED_SHADER_VALS["chaos"])-1
	)
	chaos_value_at_rest = WEEB_TOUCHED_SHADER_VALS["chaos"][array_index]
	blue_div_at_rest = WEEB_TOUCHED_SHADER_VALS["blue"][array_index]
	weeb_touched += 1
	character_pointer.take_damage(1, max_hitpoints-weeb_touched)
	set_tape_hit_mode()

func set_tape_hit_mode():
	tween_disk_color(Color.RED, 0.1, 90.0, 5.0, 1.75)
	damaging = true
	damaging_timer = DAMAGING_TIME_MIN
	linear_damp = 3.5
	angular_damp = 0.5

func set_tape_rest_mode():
	tween_disk_color(Color.DARK_CYAN, 0.45, chaos_value_at_rest, 1.0, blue_div_at_rest)
	damaging = false
	linear_damp = 0.3
	angular_damp = 2.0

func tween_disk_color(new_color : Color, time : float, chaos : float, div_green : float, div_blue : float):
	var tween := create_tween().set_parallel()
	tween.tween_property(trail_effect, "modulate", new_color, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/chaos", chaos, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_green", div_green, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_blue", div_blue, time)

func get_hit_owner():
	return last_player_hit

func add_impulse(hit_position : Vector2, hit_intensity : float):
	var impulse_dir : Vector2 = (global_position-hit_position).normalized()
	apply_impulse( (impulse_dir + Vector2(0, -0.175)) * anime_velocity * hit_intensity )

func hit(damage : int, attacker : Node2D, hit_position : Vector2, hit_intensity := 1.0):
	if attacker != null:
		set_tape_hit_mode()
		add_impulse(hit_position, hit_intensity)
	emit_signal("hentai_hit", damage)
	GameInfos.camera_utils.shake()
	last_player_hit = attacker
	last_hit_value = damage

func _on_area_2d_body_entered(body : Node2D):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if winning_by_weeb_touch and player_body.current_evolution == PlayerCharacter.Evolutions.Weeb and not damaging:
		if weeb_touched >= max_hitpoints - 1:
			GameInfos.last_winner = player_body.player_ID
			$AudioWeebTouched.pitch_scale = 0.25
			$AudioWeebTouched.play()
			character_pointer.take_damage(1, 0)
			emit_signal("game_won")
		else:
			GameInfos.freeze_frame.freeze(0.025)
			GameInfos.camera_utils.flash_saturation(3.0, 0.6)
			GameInfos.freeze_frame.slow_mo(0.1, 0.3)
			GameInfos.camera_utils.shake()
			last_player_hit = body
			last_hit_value = 1
			var array_index : int = min(
				weeb_touched, len(WEEB_TOUCHED_SHADER_VALS["hit"])-1
			)
			var hit_intensity : float = WEEB_TOUCHED_SHADER_VALS["hit"][array_index]
			add_impulse(body.global_position, hit_intensity)
			var player_impulse := Vector2(body.global_position-global_position).normalized()
			player_body.knockback_velocity += player_impulse * anime_velocity * 2.5
			increment_weeb_touched()
	elif damaging and last_player_hit != null and body != last_player_hit:
		player_body.hit(last_hit_value * anime_damage_multiplier, self, global_position)
