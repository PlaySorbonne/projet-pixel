extends VaultTaglinesSubScreen


func _ready():
	super._ready()
	var screen_items : Array[VaultData.VaultItem] = []
	for s : VaultData.VaultItem in (VaultData.vault_gamemodes + VaultData.vault_levels 
	+ VaultData.vault_artwork + VaultData.vault_music):
		if s.item_name in VaultData.vault_data["unlocked_items"]:
			screen_items.append(s)
	var first_object : InfosTagline = add_objects(screen_items)
	grab_control_node = first_object
	for tagline : InfosTagline in $ScrollContainer/VBoxItems.get_children():
		tagline.connect("pressed", item_pressed.bind(tagline))

func item_pressed(item : InfosTagline):
	print("item.name = " + item.item_name)
	print("VaultData.all_items = " + str(VaultData.all_items))
	var vault_item : VaultData.VaultItem = VaultData.all_items[item.item_name]
	var obj : Node = load(vault_item.item_path).instantiate()
	Vault.vault_canvas_layer.add_child(obj)
