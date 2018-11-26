extends CanvasLayer

signal start_game

func update_currency(sc, hc):
	var scField = $hbox/field_softCurrency
	scField.text = str(sc)
	
	var hcField = $hbox/field_hardCurrency
	hcField.text = str(hc)

func _ready():
	#global.connect("quest_complete", self, "_on_quest_complete")
	#$button_collectQuest.hide()
	#only show quest button if quest is actually active (active = counting down AND/OR ready to collect)
	#if (!global.questActive):
		#$button_collectQuest.hide()
	#else:
		#quest is active, show the button
		#$button_collectQuest.show()
	pass
	
func _on_quest_complete(name):
	#quest is done, button sits ready to click until collected by player 
	#$button_collectQuest.set_disabled(false)
	pass
	
func _on_button_collectQuest_pressed():
	if (global.questReadyToCollect):
		get_tree().change_scene("res://menus/questComplete.tscn")
	else:
		get_tree().change_scene("res://menus/questConfirm.tscn")
