extends FighterCharacter
class_name PlayerCharacter

enum Controls {KEYBOARD, CONTROLLER}

@export var speed := 600.0
@export var jump_velocity := 600.0
@export var jump_duration := 0.2
@export var weight_multiplier := 2.5
@export var attack_damage := 1
@export var attack_intensity := 1 #for breaking super armor and flying velocity
@export var attack_duration := 0.125
@export var attack_wind_up := 0.0
@export var attack_recovery := 0.3


var control_device: int = 0
var control_type: Controls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var AttackLocation = $AttackLocation
var facing_right := true
var can_attack := true
var attacking := false
var is_jumping := false
var can_evolve := false

func set_control_device(device: int):
	control_device = device

func set_control_type(type: int):
	control_type = type

func _physics_process(delta):
	if (not is_on_floor()) and (not is_jumping):
		velocity.y += gravity * delta * weight_multiplier
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
			#velocity.y = -50.0
			is_jumping = false
			$JumpTimer.stop()
		
		if not attacking:
			# Handle normal attack
			if event.is_action_pressed("attack"):
				attack()
			
			# Handle special 
			elif event.is_action_pressed("special"):
				if can_evolve:
					evolve()
				else:
					special()
		
		# Handle movement
		if event.is_action_pressed("right"):
			velocity.x = speed
		elif event.is_action_pressed("left"):
			velocity.x = -speed
		elif (event.is_action_released("right") && velocity.x > 0) || (
		event.is_action_released("left") && velocity.x < 0):
			velocity.x = 0

func jump():
	velocity.y = -jump_velocity
	is_jumping = true
	$JumpTimer.start(jump_duration)

func _on_jump_timer_timeout():
	is_jumping = false

func evolve():
	pass

func special():
	attacking = true
	print("character [" + str(character_id) + "] special !")
	await get_tree().create_timer(1.0).timeout
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

func check_turn(right  : bool):
	if right != facing_right and not attacking:
		facing_right = right
		scale.x *= -1
