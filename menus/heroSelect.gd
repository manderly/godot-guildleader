extends Node2D
#heroSelect.gd
#use this menu to pick a hero to assign to a quest

func _ready():
	var buttonX = 0
	var buttonY = 100
	print(global.guildRoster.size())
	for i in range(global.guildRoster.size()):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		$scroll/vbox.add_child(heroButton) 
		buttonY += 130

func _on_back_button_pressed():
	global.currentMenu = "questConfirm"
	get_tree().change_scene("res://menus/questConfirm.tscn")
