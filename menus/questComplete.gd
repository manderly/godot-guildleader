extends Node2D
#questComplete.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

func _ready():
	#quest name, description
	populate_fields(global.currentQuest)
		
	#create X number of hero buttons to hold selected heroes for this specific quest
	for i in range(global.currentQuest.groupSize): 
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		#if a hero has been picked via this button, display hero's name
		if (global.questHeroes[i] != null):
			heroButton.display_hero_name(global.questHeroes[i].heroName)
		heroButton.set_button_id(i)
		heroButton.set_disabled(true)
		$hbox.add_constant_override("separation", 10)
		$hbox.add_child(heroButton)
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text
	$field_sc.text = str(global.questPrizeSC) + " coins" #set in global when the quest timer expires
	$field_hc.text = str(global.questPrizeHC) + " diamonds"
	$field_lootName1.text = global.questPrizeItem1
	$field_lootName2.text = global.questPrizeItem2

func _on_button_collectRewards_pressed():
	print("COLLECTING PRIZES AND GOING BACK TO MAIN")
	#COLLECT coins, xp, inventory items into player's real inventory
	global.softCurrency += global.questPrizeSC
	global.hardCurrency += global.questPrizeHC
	#we have the item's name, now get its actual entity and give it to the guildItems array
	if (global.questPrizeItem1):
		#todo: make sure the vault has room for it first 
		#todo: this method should be global because the same logic is used in popup_itemInfo.gd
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[global.questPrizeItem1]
				break
		
	if (global.questPrizeItem2):
		global.guildItems.append(global.allGameItems[global.questPrizeItem2])
		#todo: make sure the vault has room for it first 
		#todo: this method should be global because the same logic is used in popup_itemInfo.gd
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[global.questPrizeItem2]
				break
	
	#give xp to each hero in quest list, set status back to available, clear them out of the quest array
	for i in range(global.questHeroes.size()):
		if (global.questHeroes[i] != null):
			global.questHeroes[i].xp += global.currentQuest.xp
			#if there's xp overflow, set xp to level total 
			if (global.questHeroes[i].xp > global.levelXpData[global.questHeroes[i].level].total):
				global.questHeroes[i].xp = global.levelXpData[global.questHeroes[i].level].total
			global.questHeroes[i].available = true
			global.questHeroes[i] = null
			global.questHeroesPicked -= 1
	
	global.questPrizeItem1 = null
	global.questPrizeItem2 = null
	global.questReadyToCollect = false
	get_tree().change_scene("res://main.tscn")
	
func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
