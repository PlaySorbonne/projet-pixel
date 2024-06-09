extends FighterCharacter
class_name PlayerCharacter

enum Controls {KEYBOARD, CONTROLLER}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var attack_damage := 1
@export var attack_intensity := 1 #for breaking super armor and flying velocity
@export var attack_duration := 0.4


var control_device: int = 0
var control_type: Controls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var AttackLocation = $AttackLocation

func set_control_device(device: int):
	control_device = device
	
func set_control_type(type: int):
	control_type = type

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
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
			velocity.y = JUMP_VELOCITY
		
		if event.is_action_pressed("attack"):
			Hitbox.spawn_hitbox(self, attack_damage, AttackLocation.position, 0.3, true, 
				attack_intensity, Vector2.ONE)
		
		elif event.is_action_pressed("special"):
			print("character [" + str(character_id) + "] special !")
		
		elif event.is_action_pressed("right"):
			velocity.x = SPEED
			check_turn(true)
		elif event.is_action_pressed("left"):
			velocity.x = -SPEED
			check_turn(false)
		elif (event.is_action_released("right") && velocity.x > 0) || (
		event.is_action_released("left") && velocity.x < 0):
			velocity.x = 0

func check_turn(right  : bool):
	if right != facing_right:
		facing_right = right
		scale.x *= -1
