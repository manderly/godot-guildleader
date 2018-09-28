extends "room.gd"
#blacksmith.gd
#inherits all of room's methods 

func _ready():
	if (global.blacksmithHero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "blacksmithing"
	if (!global.blacksmithHero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")
