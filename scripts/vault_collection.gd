extends VaultSubScreen
class_name VaultTaglinesSubScreen

const TAGLINE_RES := preload("res://scenes/Menus/Vault/infos_tagline.tscn")


func _ready():
	for infos_tagline : InfosTagline in $ScrollContainer/VBoxItems.get_children():
		infos_tagline.connect("focus_entered", tagline_focused.bind(infos_tagline))

func tagline_focused(tagline : InfosTagline):
	grab_control_node = tagline
	$LabelItemTitle.text = tagline.item_name
	$LabelItemDescription.text = tagline.item_description

func add_objects(screen_items : Array[VaultData.VaultItem]) -> InfosTagline:
	for c : Control in $ScrollContainer/VBoxItems.get_children():
		c.queue_free()
	var first_object : InfosTagline = null
	for item : VaultData.VaultItem in screen_items:
		var tagline := TAGLINE_RES.instantiate()
		tagline.item_name = item.item_name
		tagline.item_description = item.item_description
		tagline.item_type = VAULT_TO_SHOP_TYPE[item.item_type]
		$ScrollContainer/VBoxItems.add_child(tagline)
		tagline.connect("focus_entered", tagline_focused.bind(tagline))
		if first_object == null:
			first_object = tagline
	return first_object
	
