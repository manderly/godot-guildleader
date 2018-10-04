extends "room.gd"
#alchemy.gd
#inherits all of room's methods 

func _ready():
	if (global.alchemyHero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "alchemy"
	if (!global.alchemyHero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")

func _process(delta):
	if (global.alchemyInProgress):
		$button_inProgress.show()
	else:
		$button_inProgress.hide()