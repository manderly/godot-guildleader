extends Node2D
#heroSelect.gd

func _ready():
	var buttonX = 0
	var buttonY = 100
	print(playervars.guildRoster.size())
	for i in range(playervars.guildRoster.size()):
		print(playervars.guildRoster[i]);
		var heroButton = preload("res://menus/heroSelect_heroButton.tscn").instance()
		heroButton.set_hero_data(playervars.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		add_child(heroButton) 
		buttonY += 130



func _on_back_button_pressed():
	print("going back")
	get_tree().change_scene("res://questConfirm.tscn");
