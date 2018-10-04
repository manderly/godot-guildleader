extends "room.gd"
#fletching.gd
#inherits all of room's methods 

func _ready():
	if (global.fletchingHero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "fletching"
	if (!global.fletchingHero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")

func _process(delta):
	if (global.fletchingInProgress):
		$button_inProgress.show()
	else:
		$button_inProgress.hide()