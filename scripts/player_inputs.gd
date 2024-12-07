extends Node
class_name PlayerInputs

@onready var player : PlayerCharacter = self.get_parent()

func _input(event : InputEvent):
	var is_correct_control_type = false
	if player.control_type == 0:
		is_correct_control_type = event is InputEventKey
	elif player.control_type == 1:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if is_correct_control_type && event.device == player.control_device:
		# Handle movement
		if event.is_action_pressed("right"):
			player.right_pressed = true
		elif event.is_action_released("right"):
			player.right_pressed = false
		if event.is_action_pressed("left"):
			player.left_pressed = true
		elif event.is_action_released("left"):
			player.left_pressed = false
		if event.is_action_pressed("up"):
			player.up_pressed = true
		elif event.is_action_released("up"):
			player.up_pressed = false
		if event.is_action_pressed("drop"):
			player.down_pressed = true
		elif event.is_action_released("drop"):
			player.down_pressed = false
		if not player.alive:
			return
		
		# Handle jump.
		if event.is_action_pressed("jump"):
			player.jump()
		elif event.is_action_released("jump") and player.velocity.y < -50.0:
			player.stop_jump()
		if not player.attacking:
			# Handle normal attack
			if event.is_action_pressed("attack"):
				player.attack()
			# Handle special 
			elif event.is_action_pressed("special"):
				player.special()
		
		if event.is_action_pressed("debug_button") and (
					player.current_evolution != PlayerCharacter.Evolutions.Weeb):
			player.evolve(player.current_evolution + 1)
