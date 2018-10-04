extends "room.gd"
#tailoring.gd
#inherits all of room's methods 

func _ready():
	if (global.tailoringHero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "tailoring"
	if (!global.tailoringHero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")

func _process(delta):
	if (global.tailoringInProgress):
		$button_inProgress.show()
	else:
		$button_inProgress.hide()