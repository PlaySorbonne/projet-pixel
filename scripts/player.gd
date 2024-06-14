extends FighterCharacter
class_name PlayerCharacter

signal player_evolved

enum Controls {KEYBOARD, CONTROLLER}
enum Evolutions {CEO, CryptoBro, Employee, Mascot, Weeb}
const EvolutionCharacters = {
	Evolutions.CEO : preload("res://scenes/Characters/Evolutions/ceo_character.tscn"),
	Evolutions.CryptoBro : preload("res://scenes/Characters/Evolutions/crypto_bro_character.tscn"),
	Evolutions.Employee : preload("res://scenes/Characters/Evolutions/employee_character.tscn"),
	Evolutions.Mascot : preload("res://scenes/Characters/Evolutions/mascot_character.tscn"),
	Evolutions.Weeb : preload("res://scenes/Characters/Evolutions/weeb_character.tscn")
}

@export var current_evolution : Evolutions = Evolutions.CEO
@export var speed := 600.0
@export var jump_velocity := 600.0
@export var jump_max_duration := 0.2
@export var fall_speed_multiplier := 2.5
@export var attack_damage := 1
@export var attack_intensity := 1 #for breaking super armor and knockback speed
@export var attack_duration := 0.125
@export var attack_wind_up := 0.0
@export var attack_recovery := 0.3
@export var initial_fall_speed := 100
@export var knockback_multiplier := 1.0
@export var knockback_damage_threshold := 1


@onready var specialObj : BaseSpecial = $SpecialAttack
@onready var AttackLocation = $AttackLocation
var control_device: int = 0
var control_type: Controls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right := true
var can_attack := true
var attacking := false
var is_jumping := false
var movement_velocity := Vector2.ZERO
var knockback_velocity := Vector2.ZERO
var computing_movement := true

func copy_player_data(new_body : PlayerCharacter):
	new_body.character_id = character_id
	new_body.team = team
	new_body.control_device = control_device
	new_body.control_type = control_type

func _ready():
	super._ready()
	_update_debug_text()

func _update_debug_text():
	$EvolutionLabel.text = "P" + str(character_id) + ":" + str(Evolutions.keys()[current_evolution]) + " " + str(hitpoints) + "/" + str(max_hitpoints)

func set_control_device(device: int):
	control_device = device

func set_control_type(type: int):
	control_type = type

func _physics_process(delta):
	if computing_movement and (not is_jumping):
		movement_velocity 
		if is_on_floor():
			movement_velocity.y = initial_fall_speed
		else:
			movement_velocity.y += gravity * delta * fall_speed_multiplier
	if computing_movement:
		velocity = movement_velocity + knockback_velocity
		knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.075)
	if velocity.x > 10.0:
		check_turn(true)
	elif velocity.x < -10.0:
		check_turn(false)
	move_and_slide()

func _input(event : InputEvent):
	var is_correct_control_type = false
	if control_type == 0:
		is_correct_control_type = event is InputEventKey
	elif control_type == 1:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if is_correct_control_type && event.device == control_device:
		# Handle jump.
		if event.is_action_pressed("jump") and is_on_floor():
			jump()
		elif event.is_action_released("jump") and velocity.y < -50.0:
			stop_jump()
		# Handle movement
		if event.is_action_pressed("right"):
			movement_velocity.x = speed
		elif event.is_action_pressed("left"):
			movement_velocity.x = -speed
		elif (event.is_action_released("right") && movement_velocity.x > 0) || (
		event.is_action_released("left") && movement_velocity.x < 0):
			movement_velocity.x = 0
		
		if not attacking:
			# Handle normal attack
			if event.is_action_pressed("attack"):
				attack()
			
			# Handle special 
			elif event.is_action_pressed("special"):
				special()

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

func spawn(location : Vector2):
	super.spawn(location)
	facing_right = true
	_update_debug_text()

func evolve():
	if current_evolution == Evolutions.Weeb:
		return
	var new_body : PlayerCharacter = EvolutionCharacters[current_evolution+1].instantiate()
	print("current_evolution+1=" + str(current_evolution+1))
	print("EvolutionCharacters[current_evolution+1]=" + str(EvolutionCharacters[current_evolution+1]))
	print("Evolutions[current_evolution+1]= " + str(str(Evolutions.keys()[current_evolution+1])))
	var player_index : int = GameInfos.players.find(self)
	print("found self in GameInfos.players at " + str(player_index))
	GameInfos.players[player_index] = new_body
	get_parent().add_child(new_body)
	print("new_body = " + str(new_body))
	await get_tree().create_timer(0.5).timeout
	copy_player_data(new_body)
	new_body.spawn(position)
	set_player_active(false)
	emit_signal("player_evolved", new_body)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func death():
	super.death()

func hit(damage : int, attacker : Node2D = null):
	super.hit(damage, attacker)
	if attacker != null and damage >= knockback_damage_threshold:
		knockback_velocity = (self.global_position - attacker.global_position
		).normalized() * knockback_multiplier * 750.0 * damage
	_update_debug_text()

func special():
	attacking = true
	specialObj.special()
	attacking = false

func attack():
	if not can_attack:
		return
	can_attack = false
	if attack_wind_up > 0:
		await get_tree().create_timer(attack_wind_up).timeout
	Hitbox.spawn_hitbox(self, attack_damage, AttackLocation.position, 0.3, true, 
	attack_intensity, Vector2.ONE)
	attacking = true
	if attack_recovery > 0:
		await get_tree().create_timer(attack_duration+attack_recovery).timeout
	can_attack = true
	attacking = false

func check_turn(right: bool):
	if right != facing_right and not attacking:
		facing_right = right
		scale.x *= -1

func _on_fighter_killed_opponent():
	evolve()
