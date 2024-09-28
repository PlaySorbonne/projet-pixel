extends PlayerCharacter
class_name WeebCharacter

signal weeb_ascended(weeb : WeebCharacter)
signal weeb_descended(weeb : WeebCharacter)

@export var ascended_weeb_hitpoints := 5

var ascended := false

func ascend():
	emit_signal("weeb_ascended", self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	ascended = true

func descend():
	emit_signal("weeb_descended", self)
	ascended = false
