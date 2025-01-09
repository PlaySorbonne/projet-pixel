extends Control
class_name CreditsScreen

signal ButtonBackPressed


func _on_button_back_pressed():
	$ButtonBack.release_focus()
	emit_signal("ButtonBackPressed")


"""
Tout le monde:
	
"""



"""

Doublage: 
	 Annonceur: Octave Donatella
	 CEO: Firion
	 Manager: Nathaaaan
	 Employée: Athenaïs
	 Mascotte: Maxence Maire
	 Weeb: Loona Macabre

M
"""
