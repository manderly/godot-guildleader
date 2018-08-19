extends CanvasLayer

signal start_game

func update_currency(sc, hc):
	var scField = $GUI/vbox_currencies/HBoxContainer/field_softCurrency
	scField.text = str(sc)
	
	var hcField = $GUI/vbox_currencies/HBoxContainer/field_hardCurrency
	hcField.text = str(hc)

func _ready():
	global.connect("quest_complete", self, "_on_quest_complete")
	
	#only show quest button if quest is actually active (active = counting down AND/OR ready to collect)
	if (!global.questActive):
		$button_collectQuest.hide()
	else:
		#quest is active, show the button
		$button_collectQuest.show()
		if (!global.questReadyToCollect):
			#quest is not ready to collect, the button is disabled
			#todo: button isn't disabled, clicking it prompts player to spend diamonds to finish it now
			$button_collectQuest.set_disabled(true)
	
func _on_quest_complete(name):
	#quest is done, button sits ready to click until collected by player 
	$button_collectQuest.set_disabled(false)
	
func _on_button_collectQuest_pressed():
	get_tree().change_scene("res://menus/questComplete.tscn")
