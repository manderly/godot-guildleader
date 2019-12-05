extends ConfirmationDialog

var nameGenerator = load("res://nameGenerator.gd").new()

signal heroNameUpdated()
signal heroNameInvalid(candidateName)
signal guildNameUpdated()

var mode = "" #set to first or last 
var candidateName = ""

func _ready():
	pass

	
func set_candidate_name(nameStr):
	candidateName = nameStr

func set_mode(modeStr): #"first" or "last"
	mode = modeStr
	if (modeStr == "first"):
		dialog_text = "Enter up to 15 letters for this hero's first name.\nNo spaces, numbers, or symbols."
		$LineEdit.text = global.selectedHero.get_first_name()
	elif (modeStr == "last"):
		dialog_text = "Enter up to 15 letters for this hero's last name.\nSpaces and accent marks ' and ` accepted. \nLeave blank to remove last name."
		$LineEdit.text = global.selectedHero.get_last_name()
	elif (modeStr == "guild"):
		dialog_text = "Enter up to 25 letters for your guild's name. \n Spaces and accent marks ' and ` accepted."
		$LineEdit.max_length = 25
		$LineEdit.text = global.guildName
	else:
		print("confirm rename dialog mode not set!")
	
func _on_confirm_rename_dialog_confirmed():
	if (mode == "first"):
		if (nameGenerator.checkIfNameInUse(candidateName) || candidateName == ""):
			emit_signal("heroNameInvalid", candidateName)
		else:
			global.selectedHero.set_first_name(candidateName)
			emit_signal("heroNameUpdated")
	elif (mode == "last"):
		global.selectedHero.set_last_name(candidateName)
		emit_signal("heroNameUpdated")
	elif (mode == "guild"):
		global.guildName = candidateName
		emit_signal("guildNameUpdated")
	else:
		print("confirm rename dialog mode not set!")
	
	

