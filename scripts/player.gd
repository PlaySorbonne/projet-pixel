extends FighterCharacter
class_name PlayerCharacter

enum Controls {KEYBOARD, CONTROLLER}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var control_device: int = 0
@export var control_type: Controls

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
			print("character [" + str(character_id) + "] attack !")
		
		elif event.is_action_pressed("special"):
			print("character [" + str(character_id) + "] special !")
		
		elif event.is_action_pressed("right"):
			velocity.x = SPEED
		elif event.is_action_pressed("left"):
			velocity.x = -SPEED
		elif (event.is_action_released("right") && velocity.x > 0) || (
		event.is_action_released("left") && velocity.x < 0):
			velocity.x = 0
