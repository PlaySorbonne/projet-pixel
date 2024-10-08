extends VaultSubScreen

@export var overwrite_infos_title := true

func _ready():
	for infos_tagline : InfosTagline in $ScrollContainer/VBoxItems.get_children():
		infos_tagline.connect("focus_entered", tagline_focused.bind(infos_tagline))

func tagline_focused(tagline : InfosTagline):
	grab_control_node = tagline
	if overwrite_infos_title:
		$LabelItemTitle.text = tagline.item_name
	$LabelItemDescription.text = tagline.item_description
