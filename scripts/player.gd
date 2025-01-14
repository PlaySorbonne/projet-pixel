extends FighterCharacter
class_name PlayerCharacter

signal has_special(new_special : bool)
signal player_evolved
signal eliminated(player : PlayerCharacter)

signal damage_taken(player : PlayerCharacter, amount : int)
signal damage_given(player : PlayerCharacter, amount : int)
signal player_kill

enum Controls {KEYBOARD, CONTROLLER}
enum Evolutions {CEO, Manager, Employee, Mascot, Weeb}
const EvolutionCharacters = {
	Evolutions.CEO : preload("res://scenes/Characters/Evolutions/ceo_character.tscn"),
	Evolutions.Manager : preload("res://scenes/Characters/Evolutions/manager_character.tscn"),
	Evolutions.Employee : preload("res://scenes/Characters/Evolutions/employee_character.tscn"),
	Evolutions.Mascot : preload("res://scenes/Characters/Evolutions/mascot_character.tscn"),
	Evolutions.Weeb : preload("res://scenes/Characters/Evolutions/weeb_character.tscn")
}
const EVOLUTIONS_AIS := {
	Evolutions.CEO : preload("res://scenes/Characters/inputs/ai_inputs_ceo.tscn"),
	Evolutions.Manager : preload("res://scenes/Characters/inputs/ai_inputs_ceo.tscn"),
	Evolutions.Employee : preload("res://scenes/Characters/inputs/ai_inputs_employee.tscn"),
	Evolutions.Mascot : preload("res://scenes/Characters/inputs/ai_inputs_employee.tscn"),
	Evolutions.Weeb : preload("res://scenes/Characters/inputs/ai_inputs_weeb.tscn")
}

static var player_counter := 0

@export var is_player_controlled := true
@export var ai_difficulty := AI_Inputs.Difficulty.Mid
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
var ascended := false
var is_first_evolution := true
var control_device: int = 0
var control_type: Controls
var is_eliminated := false
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
var down_pressed := false:
	set(value):
		down_pressed = value
		set_collision_mask_value(5, not value)
var compute_hits := true
var in_stun_time := false
var eliminate_hit_targets := false
var player_color : Color
var player_stats : PlayerStats = null
var is_super_weeb := false

func load_custom_gameplay_data():
	var ev : String = Evolutions.find_key(current_evolution)
	for k : String in SettingsScreen.gameplay_data[ev].keys():
		set(k, SettingsScreen.gameplay_data[ev][k])
	var ev_spe := ev + "_special"
	for k : String in SettingsScreen.gameplay_data[ev_spe].keys():
		get_special_attack().set(k, SettingsScreen.gameplay_data[ev_spe][k])
	if air_speed <= 1.0:
		air_speed = speed

func get_attack_location() -> Vector2:
	return $AttackLocation.global_position

func get_special_attack() -> Node:
	return $SpecialAttack

func copy_player_data(new_body : PlayerCharacter, in_lobby := false):
	new_body.team = team
	new_body.control_device = control_device
	new_body.control_type = control_type
	new_body.player_ID = player_ID
	new_body.is_player_controlled = is_player_controlled
	new_body.ai_difficulty = ai_difficulty
	new_body.set_player_color(GameInfos.players_data[player_ID]["color"])
	new_body.player_stats = player_stats
	new_body.is_first_evolution = in_lobby

func _init():
	if not GameInfos.game_started:
		player_ID = player_counter
		player_counter += 1

func _ready():
	super._ready()
	if not GameInfos.teams_active:
		team = player_ID
	set_player_color(GameInfos.players_data[player_ID]["color"])
	load_custom_gameplay_data()
	var sfx_pitch_modulation : float = 0.6 + float(current_evolution+1) / 5.0
	$AudioHit.pitch_scale = sfx_pitch_modulation
	$CharacterPointer.set_character_name(GameInfos.players_data[player_ID]["name"])
	if is_player_controlled:
		const PLAYER_INPUTS_RES := preload("res://scenes/Characters/inputs/player_inputs.tscn")
		self.add_child(PLAYER_INPUTS_RES.instantiate())
	else:
		self.add_child(EVOLUTIONS_AIS[current_evolution].instantiate())
	if not is_first_evolution:
		await get_tree().create_timer(1.2).timeout
		$AudioLineEvolve.stream = audio_evolve.pick_random()
		$AudioLineEvolve.play()
	$CharacterPointer.player_id = player_ID

func set_player_color(new_color : Color):
	player_color = new_color
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

var is_hurt_anim := false
func set_animation(force := false):
	if not computing_movement and not force:
		return
	if not alive:
		#$Sprite2D.play("death")
		$AnimationPlayer.play("death")
	elif in_invincibility_time or is_hurt_anim:
		#$Sprite2D.play("hit")
		if not is_hurt_anim:
			is_hurt_anim = true
			$HurtAnimTimer.start(0.6)
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

func stop_jump():
	if velocity.y < -50.0:
		movement_velocity.y = -50.0
		is_jumping = false
		$JumpTimer.stop()

func jump():
	if not alive or not is_on_floor():
		return
	movement_velocity.y = -jump_velocity
	is_jumping = true
	$JumpTimer.start(jump_max_duration)

func _on_jump_timer_timeout():
	is_jumping = false

func spawn(location : Vector2, activate := true, f_right := true):
	super.spawn(location, activate, f_right)
	#facing_right = f_right
	check_turn(f_right)
	movement_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	GameInfos.tracked_targets.append(self)
	await self.player_spawned
	computing_movement = true
	$CharacterPointer.set_max_hitpoints(max_hitpoints)

func evolve(next_evolution : Evolutions, in_lobby := false):
	if evolving or ascended:
		return
	if next_evolution == null:
		next_evolution = current_evolution + 1
	evolving = true
	compute_hits = false
	computing_movement = false
	$AnimationPlayer.stop()
	$EvolveAnimation.speed_scale = 1.5
	$EvolveAnimation.play("evolve")
	controller_vibration(1.0, 0.4)
	var sfx_pitch_modulation : float = 0.6 + float(next_evolution) / 5.0
	$AudioEvolve.pitch_scale = sfx_pitch_modulation
	$AudioEvolve.play()
	var tween := create_tween()
	tween.tween_property($CharacterPointer, "modulate", Color.TRANSPARENT, 0.5)
	velocity = Vector2.ZERO
	# GameInfos.camera_utils.quick_zoom(GameInfos.camera.zoom*1.1, self.global_position, 0.75, 0.2)
	var new_body : PlayerCharacter = EvolutionCharacters[next_evolution].instantiate()
	GameInfos.players[player_ID] = new_body
	copy_player_data(new_body, in_lobby)
	if not in_lobby:
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
	if GameInfos.lives_limit > 0 and (player_stats.deaths+1) >= GameInfos.lives_limit and (
															hitpoints <= damage):
		self.eliminate(attacker, hit_location)
		return
	var hit_owner : Node2D
	play_hit_sfx()
	emit_signal("damage_taken", self, damage)
	if attacker != null and damage >= knockback_damage_threshold:
		knockback_velocity = ((self.global_position - hit_location
		).normalized() + Vector2(0, -0.2)) * knockback_multiplier * hit_power * 750.0 * damage
	if attacker.has_method("get_hit_owner"):
		hit_owner = attacker.get_hit_owner()
	else:
		hit_owner = attacker
	# track the player damages
	if hit_owner.has_signal("damage_given"):
		hit_owner.emit_signal("damage_given", hit_owner, damage)
	#
	if god_mode:
		super.hit(0, hit_owner, hit_location)
	else:
		super.hit(damage, hit_owner, hit_location)
	set_stunned()
	emit_hit_particles()
	GameInfos.camera_utils.shake()
	if hitpoints > 0:
		controller_vibration()
		GameInfos.freeze_frame.freeze(0.015)
		$AudioLineHurt.stream = audio_hurt.pick_random()
	else:
		# track the player kills
		if hit_owner.has_signal("player_kill"):
			hit_owner.emit_signal("player_kill")
		controller_vibration(1.0, 0.4)
		$AudioLineHurt.stream = audio_death.pick_random()
	$AudioLineHurt.play()

func controller_vibration(strength : float = 0.75, duration : float = 0.3) -> void:
	if control_type == Controls.CONTROLLER:
		Input.start_joy_vibration(control_device, strength, strength, duration)

func play_hit_sfx():
	await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
	$AudioHit.play(0.0)

func set_stunned():
	if stun_time > 0:
		$StunTimer.start(stun_time)
		in_stun_time = true

func emit_hit_particles():
	$HitParticles.amount = randi_range(8, 12)
	$HitParticles.speed_scale = randf_range(0.9, 1.0)
	$HitParticles.restart()

func special():
	if (not alive) or (not computing_movement) or (in_stun_time) or (
										not specialObj.can_use_special):
		return
	specialObj.special()
	$AudioLineSpecial.stream = audio_special.pick_random()
	$AudioLineSpecial.play()

func attack():
	if (not alive) or (not can_attack) or (in_stun_time):
		return
	can_attack = false
	if attack_wind_up > 0:
		await get_tree().create_timer(attack_wind_up).timeout
	if not alive:
		return
	var hitbox := Hitbox.spawn_hitbox(self, attack_damage, 
	AttackLocation.position, 0.3, true, attack_intensity, attack_size)
	if eliminate_hit_targets:
		hitbox.set_eliminate(true)
	controller_vibration(0.5, 0.2)
	if custom_audio_attacks != null:
		hitbox.set_audio(custom_audio_attacks)
	attacking = true
	if attack_recovery > 0:
		await get_tree().create_timer(attack_duration+attack_recovery).timeout
	can_attack = true
	attacking = false

func eliminate(attacker : Node2D, hit_location : Vector2) -> void:
	if in_invincibility_time or not alive:
		return
	is_eliminated = true
	var zoom_pos : Vector2 = (attacker.global_position + self.global_position) / 2.0
	GameInfos.world.level.level_background_death_fx(zoom_pos)
	var vel : Vector2 = hit_location.direction_to(global_position) * 6500.0
	if attacker is PlayerCharacter:
		if (attacker.facing_right and vel.x < 0.0) or (
						not attacker.facing_right and vel.x > 0.0):
			vel.x *= -1.0
	compute_hits = false
	alive = false
	computing_movement = false
	# track the player kills
	var hit_owner : Node
	if attacker.has_method("get_hit_owner"):
		hit_owner = attacker.get_hit_owner()
	else:
		hit_owner = attacker
	if hit_owner.has_signal("player_kill"):
		hit_owner.emit_signal("player_kill")
	# 
	set_collision_mask_value(1, false)
	set_collision_mask_value(5, false)
	velocity = Vector2.ZERO
	GameInfos.freeze_frame.freeze(0.05)
	GameInfos.freeze_frame.slow_mo(0.1, 0.55)
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

func check_turn(right: bool) -> void:
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

func _on_fighter_killed_opponent(quickie := false) -> void:
	var next_evolution : Evolutions
	match GameInfos.evolving_mode:
		GameInfos.EvolvingMode.Linear:
			if current_evolution == Evolutions.Weeb:
				return
			next_evolution = current_evolution + 1
		GameInfos.EvolvingMode.Random:
			var possible_evolutions := Evolutions.values().duplicate()
			possible_evolutions.erase(current_evolution)
			next_evolution = possible_evolutions.pick_random()
		GameInfos.EvolvingMode.Fixed:
			return
	if not quickie:
		await get_tree().create_timer(2.5).timeout
	if alive:
		evolve(next_evolution)

func _on_stun_timer_timeout() -> void:
	in_stun_time = false

func _on_hurt_anim_timer_timeout() -> void:
	is_hurt_anim = false
