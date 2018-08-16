extends Node2D
#questConfirm.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

func _ready():
	#quest name, description
	populate_fields(playervars.currentQuest)
	
	#create X number of hero buttons to hold selected heroes for this specific quest
	for i in range(playervars.currentQuest.groupSize): 
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		#heroButton.set_position(Vector2(buttonX, buttonY))
		if (playervars.questHeroes[i] != null):
			heroButton.display_hero_name(playervars.questHeroes[i].heroName)
		heroButton.set_button_id(i)
		$hbox.add_constant_override("separation", 10)
		$hbox.add_child(heroButton)
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text

func _on_button_beginQuest_pressed():
	print(playervars.questHeroes.size())
	print(playervars.currentQuest.groupSize)
	
	if (playervars.questHeroes.size() < playervars.currentQuest.groupSize):
		print("Not enough groupies yet")
	else:
		#playervars.questTimer.set_wait_time(playervars.currentQuest.duration)
		playervars.questTimer.set_wait_time(6)
		playervars.questTimer.start()
		get_tree().change_scene("res://main.tscn")
