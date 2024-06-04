extends CharacterBody2D

enum Controls {KEYBOARD, CONTROLLER}

@export var control_device: int = 0
@export var control_type: Controls

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

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

func _input(event):
	var condition = false

	if control_type == 0:
		condition = event is InputEventKey
	elif control_type == 1:
		condition = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if condition:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
