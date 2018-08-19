extends CanvasLayer

signal start_game

func update_currency(sc, hc):
	var scField = $GUI/vbox_currencies/HBoxContainer/field_softCurrency
	scField.text = str(sc)
	
	var hcField = $GUI/vbox_currencies/HBoxContainer/field_hardCurrency
	hcField.text = str(hc)

func _ready():
	if (!global.questReadyToCollect):
		$button_collectQuest.hide()
	else:
		$button_collectQuest.show()
	global.connect("quest_complete", self, "_on_quest_complete")
	
func _on_quest_complete(name):
	print("quest done and GUI knows about it " + name)
	$button_collectQuest.show()
	
func _on_button_collectQuest_pressed():
	print("opening quest report")
	get_tree().change_scene("res://menus/questComplete.tscn")
