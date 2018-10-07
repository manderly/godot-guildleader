extends "room.gd"
#tailoring.gd
#inherits all of room's methods 

func _ready():
	if (global.tradeskills["tailoring"].hero):
		$button_staffCraft.text = "Craft"
	else:
		$button_staffCraft.text = "Staff"

func _on_button_staffCraft_pressed():
	global.currentMenu = "tailoring"
	if (!global.tradeskills[global.currentMenu].hero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
	else:
		get_tree().change_scene("res://menus/crafting.tscn")

func _process(delta):
	if (global.tradeskills["tailoring"].inProgress && !global.tradeskills["tailoring"].readyToCollect):
		$button_inProgress.show()
		$button_inProgress/field_timeRemaining.text = util.format_time(global.tradeskills["tailoring"].timer.time_left)
	elif (global.tradeskills["tailoring"].inProgress && global.tradeskills["tailoring"].readyToCollect):
		$button_inProgress/field_timeRemaining.text = "DONE"
	else:
		$button_inProgress.hide()

func _on_button_inProgress_pressed():
	global.currentMenu = "tailoring"
	get_tree().change_scene("res://menus/crafting.tscn")
