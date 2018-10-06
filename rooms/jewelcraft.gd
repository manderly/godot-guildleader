extends "room.gd"
#jewelcraft.gd
#inherits all of room's methods 

func _ready():
	if (global.tradeskills["jewelcraft"].hero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "jewelcraft"
	if (!global.tradeskills["jewelcraft"].hero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")
