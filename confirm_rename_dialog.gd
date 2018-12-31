extends ConfirmationDialog

signal redrawHeroName()

var mode = "" #set to first or last 

func _ready():
	pass

func set_mode(modeStr): #"first" or "last"
	mode = modeStr
	
func _on_confirm_rename_dialog_confirmed():
	var newName = $LineEdit.text
	if (mode == "last"):
		global.selectedHero.heroLastName = newName #for hero page 
	elif (mode == "first"):
		global.selectedHero.heroFirstName = newName #for create hero page
	#send "redraw hero name" signal so createHero and heroPage know to update their fields
	emit_signal("redrawHeroName")
