extends Node
#Pick a quest out of a list of available quests 

func _ready():
	#print a vertically scrolling list of quest buttons
	#9/16/18 - doesn't work now that global questData isn't an array anymore
	var buttonX = 0
	var buttonY = 0
	for i in range(global.questData.size()):
		#print(quest_data[i].name) #prints each quest name that was loaded
		var questButton = preload("res://menus/questSelect_questButton.tscn").instance()
		questButton.set_quest_data(global.questData[i])
		questButton.set_position(Vector2(buttonX, buttonY))
		$scroll/vbox.add_child(questButton)
		buttonY += 140

#back button - refactor to say "back" in method name 
func _on_Button_pressed():
	get_tree().change_scene("res://main.tscn");
