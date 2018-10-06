extends "room.gd"
#alchemy.gd
#inherits all of room's methods 

func _ready():
	if (global.currentMenu == "blacksmithing" || 
		global.currentMenu == "tailoring" ||
		global.currentMenu == "alchemy" ||
		global.currentMenu == "fletching" ||
		global.currentMenu == "jewelcraft"):
		if (global.tradeskills[global.currentMenu].hero):
			$button_staffCraft.text = "Craft"
		else:
			$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "alchemy"
	if (!global.tradeskills[global.currentMenu].hero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")