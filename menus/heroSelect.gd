extends Node2D
#heroSelect.gd
#use this menu to pick a hero to assign to a quest

func _ready():
	if (global.currentMenu == "selectHeroForQuest"):
		$field_heroSelectDescription.text = "Choose a hero to go on this quest."
	elif (global.currentMenu == "blacksmith"):
		$field_heroSelectDescription.text = "Choose a hero to work at the blacksmith. While working at the blacksmith, this hero will increase his or her blacksmithing skills but will not be available for quests or raids."
		
	var buttonX = 0
	var buttonY = 100
	for i in range(global.guildRoster.size()):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		$scroll/vbox.add_child(heroButton) 
		buttonY += 130

func _on_back_button_pressed():
	if (global.currentMenu == "blacksmith"):
		global.currentMenu = "main"
		get_tree().change_scene("res://main.tscn")
	else:
		global.currentMenu = "questConfirm"
		get_tree().change_scene("res://menus/questConfirm.tscn")
