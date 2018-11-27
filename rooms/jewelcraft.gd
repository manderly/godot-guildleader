extends "room.gd"
#jewelcraft.gd
#inherits all of room's methods 

func _ready():
	draw_hero_and_button()

func draw_hero_and_button():
	if (global.tradeskills["jewelcraft"].hero):
		$button_staffCraft.text = "Craft"
		#draw the hero
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(global.tradeskills["jewelcraft"].hero) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(280, 60))
		add_child(heroScene)
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
