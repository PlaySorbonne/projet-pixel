extends BaseSpecial

const EGG = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")

@export var jump_power := 1400
@export var can_attack_cooldown := 0.25
@export var ability_cooldown := 0.6


func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	player.knockback_velocity.y -= jump_power
	EggProjectile.spawn_egg_projectile(player)
	
	await get_tree().create_timer(can_attack_cooldown).timeout
	player.attacking = false
	
	await get_tree().create_timer(ability_cooldown).timeout
	can_use_special = true
