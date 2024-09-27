extends VaultTaglinesSubScreen


func _ready():
	super._ready()
	var screen_items : Array[VaultData.VaultItem] = []
	for s : VaultData.VaultItem in (VaultData.vault_gamemodes + VaultData.vault_levels 
	+ VaultData.vault_artwork + VaultData.vault_music):
		if s.item_name in VaultData.vault_data["unlocked_items"]:
			screen_items.append(s)
	add_objects(screen_items)
