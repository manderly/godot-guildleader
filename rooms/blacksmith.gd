extends "room.gd"
#blacksmith.gd
#inherits all of room's methods 

func _ready():
	pass

func _on_button_staffCraft_pressed():
	global.currentMenu = "blacksmithing"
	if (!global.tradeskills["blacksmithing"].hero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")
