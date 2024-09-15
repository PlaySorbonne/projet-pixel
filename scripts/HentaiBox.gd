extends RigidBody2D

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

@export var anime_velocity := 1500.0
@export var anime_damage_multiplier := 1.0
@export var winning_by_weeb_touch := true

@onready var trail_effect := $TrailEffect
var team := -1
var knockback_velocity := Vector2.ZERO
var last_player_hit : PlayerCharacter = null
var last_hit_value := 0
var initial_position
var t := 0.0
var damaging := true
var damaging_timer := 0.0
var chaos_value_at_rest := 0.0
var blue_div_at_rest := 1.0
var weeb_touched : int = 0

func _ready():
	await get_tree().create_timer(0.25).timeout
	initial_position = position
	connect("game_won", GameInfos.world.end_game)
	#physics_material_override.bounce = 1.0 # maybe put bounciness, etc as parameters

func _process(delta : float):
	t += delta
	if t > 1.0:
		t = 0.0
	if not (position.x < BOUNDS and position.x > -BOUNDS and position.y < BOUNDS and position.y > -BOUNDS):
		linear_velocity = Vector2.ZERO
		position = initial_position
	if damaging_timer > 0.0:
		damaging_timer -= delta
	elif damaging and linear_velocity.length_squared() < LIMIT_SPEED_DAMAGE_DOWN:
		set_tape_rest_mode()

func increment_weeb_touched():
	chaos_value_at_rest = WEEB_TOUCHED_SHADER_VALS["chaos"][weeb_touched]
	blue_div_at_rest = WEEB_TOUCHED_SHADER_VALS["blue"][weeb_touched]
	weeb_touched += 1
	set_tape_hit_mode()

func set_tape_hit_mode():
	tween_disk_color(Color.RED, 0.1, 60.0, 5.0, 1.75)
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
	apply_impulse( (impulse_dir + Vector2(0, -0.175)) * anime_velocity * hit_intensity  )

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
	if winning_by_weeb_touch and player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		if weeb_touched >= 3:
			emit_signal("game_won")
		else:
			GameInfos.freeze_frame.freeze(0.1)
			GameInfos.camera_utils.shake()
			add_impulse(body.global_position, WEEB_TOUCHED_SHADER_VALS["hit"][weeb_touched])
			increment_weeb_touched()
	elif damaging and last_player_hit != null and body != last_player_hit:
		player_body.hit(last_hit_value * anime_damage_multiplier, self, global_position)
