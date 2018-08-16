extends Node2D
#questConfirm.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

func _ready():
	#quest name, description
	populate_fields(playervars.currentQuest)
	
	#disable the begin quest button until enough heroes are assigned
	if (playervars.questHeroesPicked < playervars.currentQuest.groupSize):
		$button_beginQuest.set_disabled(true)
	else:
		$button_beginQuest.set_disabled(false)
		
	#create X number of hero buttons to hold selected heroes for this specific quest
	for i in range(playervars.currentQuest.groupSize): 
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		#heroButton.set_position(Vector2(buttonX, buttonY))
		
		#if a hero has been picked via this button, display hero's name
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
	
	if (playervars.questHeroesPicked < playervars.currentQuest.groupSize):
		print("Not enough groupies yet")
	else:
		playervars._begin_global_quest_timer(playervars.currentQuest.duration);
		get_tree().change_scene("res://main.tscn")

func _on_button_back_pressed():
	#clear out any heroes who were assigned to quest buttons
	for i in range(playervars.questHeroes.size()):
		if (playervars.questHeroes[i] != null):
			playervars.questHeroes[i].available = true
			playervars.questHeroes[i] = null
			playervars.questHeroesPicked -= 1
	get_tree().change_scene("res://menus/questSelect.tscn")
