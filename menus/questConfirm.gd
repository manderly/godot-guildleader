extends Node2D
#questConfirm.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

func _ready():
	#quest name, description
	populate_fields(global.currentQuest)
	
	#disable the begin quest button until enough heroes are assigned
	if (global.questHeroesPicked < global.currentQuest.groupSize):
		$button_beginQuest.set_disabled(true)
	else:
		$button_beginQuest.set_disabled(false)
		
	#create X number of hero buttons to hold selected heroes for this specific quest
	var buttonX = 0
	var buttonY = 0
	#draw a hero button for each hero in the roster
	for i in range(global.currentQuest.groupSize):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		#if a hero has been picked via this button, display hero's name
		if (global.questHeroes[i] != null):
			heroButton.populate_fields(global.questHeroes[i])
		else:
			#otherwise, draw the button empty
			heroButton.make_button_empty()
			
		heroButton.set_button_id(i)
		heroButton.set_position(Vector2(buttonX, buttonY))
		$vbox.add_child(heroButton) 
		buttonY += 80
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text
	if (data.scMin > 0):
		$hbox_prizes_currency/prizes_coins/field_scRange.text = str(data.scMin) + " - " + str(data.scMax) + " coins"
	else:
		$hbox_prizes_currency/prizes_diamonds/sprite_coins.hide()
		$hbox_prizes_currency/prizes_coins/field_scRange.hide()
	
	if (data.hcMin > 0):
		$hbox_prizes_currency/prizes_diamonds/field_hcRange.text = str(data.hcMin) + " - " + str(data.hcMax) + " diamonds"
	else:
		$hbox_prizes_currency/prizes_diamonds/sprite_diamonds.hide()
		$hbox_prizes_currency/prizes_diamonds/field_hcRange.hide()
		
	#allGameItems is a dictionary of all the games items and you can get a particular item's data by name string
	if (data.item1):
		$button_item1._set_icon(global.allGameItems[data.item1].icon)
		$button_item1._set_data(global.allGameItems[data.item1])
		$button_item1._set_label(str(data.item1Chance) + "%")
		
	if (data.item2):
		$button_item2._set_icon(global.allGameItems[data.item2].icon)
		$button_item2._set_data(global.allGameItems[data.item2])
		$button_item2._set_label(str(data.item2Chance) + "%")

func _on_button_beginQuest_pressed():
	print(global.questHeroes.size())
	print(global.currentQuest.groupSize)
	
	if (global.questHeroesPicked < global.currentQuest.groupSize):
		print("Not enough groupies yet")
	else:
		global._begin_global_quest_timer(global.currentQuest.duration);
		get_tree().change_scene("res://main.tscn")

func _on_button_back_pressed():
	#clear out any heroes who were assigned to quest buttons
	for i in range(global.questHeroes.size()):
		if (global.questHeroes[i] != null):
			global.questHeroes[i].available = true
			global.questHeroes[i] = null
			global.questHeroesPicked -= 1
	get_tree().change_scene("res://menus/maps/worldmap.tscn")
