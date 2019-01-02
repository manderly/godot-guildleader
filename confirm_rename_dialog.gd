extends ConfirmationDialog

signal redrawHeroName()

var mode = "" #set to first or last 
var candidateName = ""

func _ready():
	pass
	
func set_candidate_name(nameStr):
	candidateName = nameStr

func set_mode(modeStr): #"first" or "last"
	mode = modeStr
	if (modeStr == "first"):
		$LineEdit.text = global.selectedHero.heroFirstName
	elif (modeStr == "last"):
		$LineEdit.text = global.selectedHero.heroLastName
	else:
		print("confirm rename dialog mode not set!")
	
func _on_confirm_rename_dialog_confirmed():
	if (mode == "first"):
		global.selectedHero.heroFirstName = candidateName
	elif (mode == "last"):
		global.selectedHero.heroLastName = candidateName
	else:
		print("confirm rename dialog mode not set!")
	
	#send "redraw hero name" signal so createHero and heroPage know to update their fields
	emit_signal("redrawHeroName")
