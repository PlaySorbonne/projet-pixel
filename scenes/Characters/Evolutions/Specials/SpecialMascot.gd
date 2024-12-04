extends BaseSpecial
class_name SpecialMascot

const EGG = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")

@export var jump_power := 2500.0
@export var can_attack_cooldown := 0.25
@export var ability_cooldown := 0.6
@export var egg_hit_damage : int = 1   
@export var egg_hit_duration := 1.0
@export var egg_speed := 1400.0
@export var egg_hit_size := 5.0
@export var egg_hit_intensity := 1.0


func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	if player.is_on_floor():
		player.knockback_velocity.y = -jump_power * 1.5
		EggProjectile.spawn_egg_projectile(player, self, true)
	else:
		player.knockback_velocity.y = min(
			player.knockback_velocity.y-jump_power, 
			-jump_power
		)
		EggProjectile.spawn_egg_projectile(player, self, false)
	player.controller_vibration(0.6, 0.2)
	
	await get_tree().create_timer(can_attack_cooldown).timeout
	player.attacking = false
	
	await get_tree().create_timer(ability_cooldown).timeout
	can_use_special = true
