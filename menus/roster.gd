extends Node2D
#roster.gd
#makes a long list of every hero in the player's guild
#individual heroes can be clicked on to go to their hero page 

func _ready():
	var buttonX = 0
	var buttonY = 100
	#draw a hero button for each hero in the roster
	for i in range(global.guildRoster.size()):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		add_child(heroButton) 
		buttonY += 130

func _on_back_button_pressed():
	get_tree().change_scene("res://main.tscn")