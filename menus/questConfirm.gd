extends Node2D
#questConfirm.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

func _ready():
	#quest name, description
	populate_fields(playervars.currentQuest)
	
	#create X number of hero buttons to hold selected heroes for this specific quest
	var buttonX = 0
	var buttonY = 500
	for i in range(playervars.currentQuest.groupSize):
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		heroButton.set_position(Vector2(buttonX, buttonY))
		if (playervars.questHeroes[i] != null):
			heroButton.display_hero_name(playervars.questHeroes[i].heroName)
		heroButton.set_button_id(i)
		add_child(heroButton)
		buttonX += 130
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text