extends Node
#Pick a quest out of a list of available quests 

func _ready():
	#Load quest data (todo: this should probably be done once in the global file) 
	var file = File.new()
	file.open("res://gameData/quests.json", file.READ)
	var quest_data = parse_json(file.get_as_text())
	file.close()
	
	#print a vertically scrolling list of quest buttons
	var buttonX = 0
	var buttonY = 0
	for i in range(quest_data.size()):
		#print(quest_data[i].name) #prints each quest name that was loaded
		var questButton = preload("res://menus/questSelect_questButton.tscn").instance()
		questButton.set_quest_data(quest_data[i])
		questButton.set_position(Vector2(buttonX, buttonY))
		$scroll/vbox.add_child(questButton)
		buttonY += 140

#back button - refactor to say "back" in method name 
func _on_Button_pressed():
	get_tree().change_scene("res://main.tscn");
