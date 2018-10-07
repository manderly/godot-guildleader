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

func _process(delta):
	if (global.tradeskills["jewelcraft"].inProgress && !global.tradeskills["jewelcraft"].readyToCollect):
		$button_inProgress.show()
		$button_inProgress/field_timeRemaining.text = util.format_time(global.tradeskills["jewelcraft"].timer.time_left)
	elif (global.tradeskills["jewelcraft"].inProgress && global.tradeskills["jewelcraft"].readyToCollect):
		$button_inProgress/field_timeRemaining.text = "DONE"
	else:
		$button_inProgress.hide()

func _on_button_inProgress_pressed():
	global.currentMenu = "jewelcraft"
	get_tree().change_scene("res://menus/crafting.tscn")
