extends Node

func _ready():
	var file = File.new()
	file.open("res://gameData/Quests.json", file.READ)
	var quest_data = parse_json(file.get_as_text())
	file.close()
	
	var buttonX = 0
	var buttonY = 100
	for i in range(quest_data.size()):
		#print(quest_data[i].name) #prints each quest name that was loaded
		var questButton = preload("res://menus/questSelect_questButton.tscn").instance()
		questButton.set_quest_data(quest_data[i])
		questButton.set_position(Vector2(buttonX, buttonY))
		add_child(questButton)
		buttonY += 130

func _on_Button_pressed():
	get_tree().change_scene("res://main.tscn");
