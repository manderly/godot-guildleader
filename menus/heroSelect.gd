extends Node2D
#heroSelect.gd
#use this menu to pick a hero to assign to a quest

func _ready():
	if (global.currentMenu == "selectHeroForQuest"):
		$field_heroSelectDescription.text = "Choose a hero to go on this quest."
	elif (global.currentMenu == "alchemy" || 
			global.currentMenu == "blacksmithing" || 
			global.currentMenu == "fletching" || 
			global.currentMenu == "jewelcraft" || 
			global.currentMenu == "tailoring"):
		$field_heroSelectDescription.text = "Choose a hero to work at this tradeskill. Crafting recipes will improve this hero's skill at " + global.currentMenu + ". While here, this hero will not be available for quests or raids."
		
	var buttonX = 0
	var buttonY = 100
	for i in range(global.guildRoster.size()):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		$scroll/vbox.add_child(heroButton) 
		buttonY += 130


func _on_button_back_pressed():
	if (global.currentMenu == "alchemy" || 
		global.currentMenu == "blacksmithing" || 
		global.currentMenu == "fletching" || 
		global.currentMenu == "jewelcraft" || 
		global.currentMenu == "tailoring"):
		global.currentMenu = "main"
		get_tree().change_scene("res://main.tscn")
	else:
		global.currentMenu = "questConfirm"
		get_tree().change_scene("res://menus/questConfirm.tscn")
