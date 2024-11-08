extends FighterCharacter
class_name PlayerCharacter

signal has_special(new_special : bool)
signal player_evolved
signal eliminated(player : PlayerCharacter)

enum Controls {KEYBOARD, CONTROLLER}
enum Evolutions {CEO, Manager, Employee, Mascot, Weeb}
const EvolutionCharacters = {
	Evolutions.CEO : preload("res://scenes/Characters/Evolutions/ceo_character.tscn"),
	Evolutions.Manager : preload("res://scenes/Characters/Evolutions/manager_character.tscn"),
	Evolutions.Employee : preload("res://scenes/Characters/Evolutions/employee_character.tscn"),
	Evolutions.Mascot : preload("res://scenes/Characters/Evolutions/mascot_character.tscn"),
	Evolutions.Weeb : preload("res://scenes/Characters/Evolutions/weeb_character.tscn")
}

static var player_counter := 0

@export var custom_audio_attacks : AudioStream = null

@export_group("Gameplay Stats")
@export var current_evolution : Evolutions = Evolutions.CEO
@export var attack_size := Vector2.ONE
@export var speed := 600.0
@export var air_speed := 600.0
@export var max_fall_speed := 1500.0
@export var jump_velocity := 600.0
@export var jump_max_duration := 0.2
@export var fall_speed_multiplier := 2.5
@export var attack_damage : int = 1
@export var knockback_damage_threshold : int = 1
@export var attack_intensity := 1 #for breaking super armor and knockback speed
@export var attack_duration := 0.125
@export var attack_wind_up := 0.0
@export var attack_recovery := 0.3
@export var initial_fall_speed := 100.0
@export var knockback_multiplier := 1.0
@export var knockback_interp_factor := 0.075
@export var stun_time := 0.3

@export_group("Audio lines")
@export var audio_evolve : Array[AudioStream] = []
@export var audio_death : Array[AudioStream] = []
@export var audio_special : Array[AudioStream] = []
@export var audio_hurt : Array[AudioStream] = []

@onready var specialObj : BaseSpecial = $SpecialAttack
@onready var AttackLocation = $AttackLocation
@onready var attack_loc_pos : Vector2 = $AttackLocation.position
var control_device: int = 0
var control_type: Controls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right := true
var can_attack := true
var attacking := false
var is_jumping := false
var movement_velocity := Vector2.ZERO
var knockback_velocity := Vector2.ZERO
var computing_movement := false
var god_mode := false
var player_ID := 0
var evolving := false
var left_pressed := false
var right_pressed := false
var up_pressed := false
var down_pressed := false
var compute_hits := true
var in_stun_time := false
var eliminate_hit_targets := false

func load_custom_gameplay_data():
	var ev : String = Evolutions.find_key(current_evolution)
	for k : String in SettingsScreen.gameplay_data[ev].keys():
		set(k, SettingsScreen.gameplay_data[ev][k])
	var ev_spe := ev + "_special"
	for k : String in SettingsScreen.gameplay_data[ev_spe].keys():
		get_special_attack().set(k, SettingsScreen.gameplay_data[ev_spe][k])
	if air_speed <= 1.0:
		air_speed = speed

func get_special_attack():
	return $SpecialAttack

func copy_player_data(new_body : PlayerCharacter):
	new_body.team = team
	new_body.control_device = control_device
	new_body.control_type = control_type
	new_body.player_ID = player_ID
	new_body.set_player_color(GameInfos.players_data[player_ID]["color"])

func _init():
	if not GameInfos.game_started:
		player_ID = player_counter
		player_counter += 1

func _ready():
	super._ready()
	team = player_ID
	set_player_color(GameInfos.players_data[player_ID]["color"])
	if not GameInfos.use_special_gameplay_data:
		load_custom_gameplay_data()
	var sfx_pitch_modulation : float = 0.6 + float(current_evolution+1) / 5.0
	$AudioHit.pitch_scale = sfx_pitch_modulation
	$CharacterPointer.set_character_name(GameInfos.players_data[player_ID]["name"])
	if current_evolution != Evolutions.CEO:
		await get_tree().create_timer(1.2).timeout
		$AudioLineEvolve.stream = audio_evolve.pick_random()
		$AudioLineEvolve.play()

func set_player_color(new_color : Color):
	$TrailEffect.modulate = new_color
	$CharacterPointer.self_modulate = new_color
	$Sprite2D.material.set_shader_parameter("replace_color", new_color)

func set_control_device(device: int):
	control_device = device

func set_control_type(type: int):
	control_type = type

func _physics_process(delta):
	var horizontal_input := 0.0
	if alive:
		horizontal_input = int(right_pressed) - int(left_pressed)
	if computing_movement and (not is_jumping): 
		if is_on_floor():
			movement_velocity.x = horizontal_input * speed
			movement_velocity.y = initial_fall_speed
		else:
			movement_velocity.x = horizontal_input * air_speed
			movement_velocity.y = min(
				movement_velocity.y + gravity * delta * fall_speed_multiplier, 
				max_fall_speed
			)
	if computing_movement:
		if is_jumping:
			movement_velocity.x = horizontal_input * air_speed
		# need to change the formula for knockback velocity, dosn't feel right as of yet
		velocity = movement_velocity + knockback_velocity
		if knockback_velocity != Vector2.ZERO:
			knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, knockback_interp_factor)
			if knockback_velocity.length_squared() < 250:
				knockback_velocity = Vector2.ZERO
	if not evolving:
		if movement_velocity.x > 10.0:
			check_turn(true)
		elif movement_velocity.x < -10.0:
			check_turn(false)
	move_and_slide()
	set_animation()

func reset_animation():
	#$Sprite2D.play("evolve")
	$AnimationPlayer.play("evolve")

func set_animation(force := false):
	if not computing_movement and not force:
		return
	if not alive:
		#$Sprite2D.play("death")
		$AnimationPlayer.play("death")
	elif in_invincibility_time:
		#$Sprite2D.play("hit")
		$AnimationPlayer.play("hit")
	elif attacking:
		#$Sprite2D.play("attack")
		$AnimationPlayer.play("attack")
	elif is_on_floor():
		if velocity.x > 10.0 or velocity.x < -10.0:
			#$Sprite2D.play("run")
			$AnimationPlayer.play("run")
		else:
			#$Sprite2D.play("idle")
			$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("jump")
		#$Sprite2D.play("jump")

func _input(event : InputEvent):
	var is_correct_control_type = false
	if control_type == 0:
		is_correct_control_type = event is InputEventKey
	elif control_type == 1:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if is_correct_control_type && event.device == control_device:
		# Handle movement
		if event.is_action_pressed("right"):
			right_pressed = true
		elif event.is_action_released("right"):
			right_pressed = false
		if event.is_action_pressed("left"):
			left_pressed = true
		elif event.is_action_released("left"):
			left_pressed = false
		if event.is_action_pressed("up"):
			up_pressed = true
		elif event.is_action_released("up"):
			up_pressed = false
		if event.is_action_pressed("drop"):
			down_pressed = true
			set_collision_mask_value(5, false)
		elif event.is_action_released("drop"):
			down_pressed = false
			set_collision_mask_value(5, true)
		if not alive:
			return
		
		var on_floor := is_on_floor()
		# Handle jump.
		if event.is_action_pressed("jump") and on_floor:
			jump()
		elif event.is_action_released("jump") and velocity.y < -50.0:
			stop_jump()
		if not attacking:
			# Handle normal attack
			if event.is_action_pressed("attack"):
				attack()
			# Handle special 
			elif event.is_action_pressed("special"):
				special()
		
		if event.is_action_pressed("debug_button"):# and false:
			evolve()

func stop_jump():
	if velocity.y < -50.0:
		movement_velocity.y = -50.0
		is_jumping = false
		$JumpTimer.stop()

func jump():
	movement_velocity.y = -jump_velocity
	is_jumping = true
	$JumpTimer.start(jump_max_duration)

func _on_jump_timer_timeout():
	is_jumping = false

func spawn(location : Vector2, activate := true, f_right := true):
	super.spawn(location, activate, f_right)
	facing_right = f_right
	$Sprite2D.flip_h = not f_right
	movement_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	GameInfos.tracked_targets.append(self)
	await self.player_spawned
	computing_movement = true
	$CharacterPointer.set_max_hitpoints(max_hitpoints)

func evolve(in_lobby: bool = false):
	if evolving:
		return
	if current_evolution == Evolutions.Weeb:
		if in_lobby:
			current_evolution = -1
		else:
			return
	evolving = true
	compute_hits = false
	computing_movement = false
	$AnimationPlayer.stop()
	$EvolveAnimation.speed_scale = 1.5
	$EvolveAnimation.play("evolve")
	var sfx_pitch_modulation : float = 0.6 + float(current_evolution+1) / 5.0
	$AudioEvolve.pitch_scale = sfx_pitch_modulation
	$AudioEvolve.play()
	var tween := create_tween()
	tween.tween_property($CharacterPointer, "modulate", Color.TRANSPARENT, 0.5)
	velocity = Vector2.ZERO
	# GameInfos.camera_utils.quick_zoom(GameInfos.camera.zoom*1.1, self.global_position, 0.75, 0.2)
	var new_body : PlayerCharacter = EvolutionCharacters[current_evolution+1].instantiate()
	GameInfos.players[player_ID] = new_body
	copy_player_data(new_body)
	get_parent().add_child(new_body)
	set_player_active(false)
	await get_tree().create_timer(0.7).timeout
	new_body.spawn(position, true, facing_right)
	emit_signal("player_evolved", new_body)
	GameInfos.tracked_targets.erase(self)
	await get_tree().create_timer(0.5).timeout
	queue_free()

func remove_player():
	compute_hits = true
	movement_velocity = Vector2.ZERO

func death(force := false):
	alive = false
	$AnimationPlayer.stop()
	$EvolveAnimation.speed_scale = 1.0
	if knockback_velocity.x > 0.0:
		$EvolveAnimation.play("death")
	else:
		$EvolveAnimation.play("death_left")
	compute_hits = false
	movement_velocity = Vector2.ZERO
	GameInfos.freeze_frame.freeze(0.05)
	GameInfos.freeze_frame.slow_mo(0.1, 0.35)
	await get_tree().create_timer(1.0).timeout
	compute_hits = true
	super.death(true)

func hit(damage : int, attacker : Node2D, hit_location : Vector2, hit_power := 1.0):
	if in_invincibility_time or not compute_hits:
		return
	var hit_owner : Node2D
	play_hit_sfx()
	if attacker != null and damage >= knockback_damage_threshold:
		knockback_velocity = ((self.global_position - hit_location
		).normalized() + Vector2(0, -0.2)) * knockback_multiplier * hit_power * 750.0 * damage
	if attacker.has_method("get_hit_owner"):
		hit_owner = attacker.get_hit_owner()
	else:
		hit_owner = attacker
	if god_mode:
		super.hit(0, hit_owner, hit_location)
	else:
		super.hit(damage, hit_owner, hit_location)
	set_stunned()
	emit_hit_particles()
	GameInfos.camera_utils.shake()
	if hitpoints > 0:
		GameInfos.freeze_frame.freeze(0.015)
		$AudioLineHurt.stream = audio_hurt.pick_random()
	else:
		$AudioLineHurt.stream = audio_death.pick_random()
	$AudioLineHurt.play()

func play_hit_sfx():
	await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
	$AudioHit.play(0.0)

func set_stunned():
	$StunTimer.start(stun_time)
	in_stun_time = true

func emit_hit_particles():
	$HitParticles.amount = randi_range(8, 12)
	$HitParticles.speed_scale = randf_range(0.9, 1.0)
	$HitParticles.restart()

func special():
	if in_stun_time or not specialObj.can_use_special:
		return
	specialObj.special()
	$AudioLineSpecial.stream = audio_special.pick_random()
	$AudioLineSpecial.play()

func attack():
	if not can_attack or in_stun_time:
		return
	can_attack = false
	if attack_wind_up > 0:
		await get_tree().create_timer(attack_wind_up).timeout
	var hitbox := Hitbox.spawn_hitbox(self, attack_damage, 
	AttackLocation.position, 0.3, true, attack_intensity, attack_size)
	if eliminate_hit_targets:
		hitbox.set_eliminate(true)
	if custom_audio_attacks != null:
		hitbox.set_audio(custom_audio_attacks)
	attacking = true
	if attack_recovery > 0:
		await get_tree().create_timer(attack_duration+attack_recovery).timeout
	can_attack = true
	attacking = false

func eliminate(attacker : Node2D, hit_location : Vector2):
	if in_invincibility_time or not alive:
		return
	var vel : Vector2 = hit_location.direction_to(global_position) * 6500.0
	compute_hits = false
	alive = false
	computing_movement = false
	set_collision_mask_value(1, false)
	set_collision_mask_value(5, false)
	velocity = Vector2.ZERO
	GameInfos.freeze_frame.freeze(0.05)
	GameInfos.freeze_frame.slow_mo(0.1, 0.45)
	GameInfos.camera_utils.shake(0.35, 15, 50, 5)
	await get_tree().create_timer(0.05).timeout
	velocity = vel
	GameInfos.player_portaits[player_ID].eliminate(vel)
	$Sprite2D.play("hit")
	emit_signal("eliminated", self)
	await get_tree().create_timer(0.2).timeout
	GameInfos.world.player_eliminated()
	await get_tree().create_timer(1.0).timeout
	visible = false

func check_turn(right: bool):
	if right != facing_right:# and not attacking:
		facing_right = right
		var mult : float
		if right:
			mult = 1.0
		else:
			mult = -1.0
		$Sprite2D.flip_h = not right
		AttackLocation.position = Vector2(
			attack_loc_pos.x * mult,
			attack_loc_pos.y
		)

func _on_fighter_killed_opponent():
	await get_tree().create_timer(2.5).timeout
	if alive:
		evolve()

func _on_stun_timer_timeout():
	in_stun_time = false
