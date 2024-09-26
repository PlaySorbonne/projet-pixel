extends VaultSubScreen

func _ready():
	for infos_tagline : InfosTagline in $ScrollContainer/VBoxItems.get_children():
		infos_tagline.connect("pressed", tagline_pressed.bind(infos_tagline))

func tagline_pressed(tagline : InfosTagline):
	grab_control_node = tagline
	$LabelItemTitle.text = tagline.item_name
	$LabelItemDescription.text = tagline.item_description
