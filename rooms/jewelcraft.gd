extends "room.gd"
#jewelcraft.gd
#inherits all of room's methods 

func _ready():
	if (global.jewelcraftHero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "jewelcraft"
	if (!global.jewelcraftHero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")

func _process(delta):
	if (global.jewelcraftInProgress):
		$button_inProgress.show()
	else:
		$button_inProgress.hide()