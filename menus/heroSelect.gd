extends Node2D
#heroSelect.gd
#use this menu to pick a hero to assign to a quest
onready var heroSelectDescription = $CenterContainer/VBoxContainer/field_heroSelectDescription
onready var scrollVBox = $CenterContainer/VBoxContainer/scroll/vbox

func _ready():
	print("currentMenu is: " + global.currentMenu)
	if (global.currentMenu == "alchemy" || 
			global.currentMenu == "blacksmithing" || 
			global.currentMenu == "fletching" || 
			global.currentMenu == "jewelcraft" || 
			global.currentMenu == "tailoring"):
		heroSelectDescription.text = "Choose a hero to work at this tradeskill. Crafting recipes will improve this hero's skill at " + global.currentMenu + ". While here, this hero will not be available for quests or raids."
	elif (global.currentMenu == "harvesting"):
		heroSelectDescription.text = "Choose a hero to harvest this resource."
	elif (global.currentMenu == "selectHeroForCamp"):
		heroSelectDescription.text = "Choose a hero to camp this location."
	else:
		heroSelectDescription.text = "heroSelect.gd TEXT NOT SET"
		
	var buttonX = 0
	var buttonY = 80
	for i in range(global.guildRoster.size()):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		scrollVBox.add_child(heroButton) 
		buttonY += 80


func _on_button_back_pressed():
	if (global.currentMenu == "alchemy" || 
		global.currentMenu == "blacksmithing" || 
		global.currentMenu == "fletching" || 
		global.currentMenu == "jewelcraft" || 
		global.currentMenu == "tailoring"):
		global.currentMenu = "main"
		get_tree().change_scene("res://main.tscn")
	elif (global.currentMenu == "harvesting"):
		#todo: return to correct map 
		get_tree().change_scene("res://menus/maps/forest.tscn")
	elif (global.currentMenu == "selectHeroForCamp"):
		get_tree().change_scene("res://menus/maps/camp.tscn")
	else:
		print("heroSelect.gd - back not handled") 
