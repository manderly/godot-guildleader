extends ConfirmationDialog

signal redrawHeroName()

func _ready():
	pass

func _on_confirm_rename_dialog_confirmed():
	var newName = $LineEdit.text
	global.selectedHero.heroName = newName
	#send "redraw hero name" signal so createHero and heroPage know to update their fields
	emit_signal("redrawHeroName")
