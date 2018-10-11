extends "room.gd"
#tailoring.gd
#inherits all of room's methods 

func _ready():
	if (global.tradeskills["tailoring"].hero):
		$button_staffCraft.text = "Craft"
		#draw the hero
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(global.tradeskills["tailoring"].hero) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(280, 60))
		add_child(heroScene)
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
