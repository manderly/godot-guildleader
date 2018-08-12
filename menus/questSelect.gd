extends Node

func _ready():

	var file = File.new()
	file.open("res://gameData/Quests.json", file.READ)
	var quest_data = parse_json(file.get_as_text())
	file.close()
	# print(quest_data)
	
	var buttonX = 0
	var buttonY = 100
	for i in range(quest_data.size()):
			print(quest_data[i].name)
			var questButton = preload("res://menus/questSelect_questButton.tscn").instance()
			questButton.populate_fields(quest_data[i])
			questButton.set_position(Vector2(buttonX, buttonY))
			add_child(questButton) #put it on stage (child of main)
			buttonY += 100

func _on_Button_pressed():
	get_tree().change_scene("res://main.tscn");
	pass # replace with function body
