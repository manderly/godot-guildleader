extends Node2D
#questComplete.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 

var currentQuest = null

func _ready():
	#quest name, description
	currentQuest = global.questData[global.selectedQuestID]
	populate_fields(currentQuest)
		
	#create X number of hero buttons to hold selected heroes for this specific quest
	for i in range(currentQuest.heroes.size()): 
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		#if a hero has been picked via this button, display hero's name
		if (currentQuest.heroes[i] != null):
			heroButton.display_hero_name(currentQuest.heroes[i].heroName)
		heroButton.set_button_id(i)
		heroButton.set_disabled(true)
		$hbox.add_constant_override("separation", 10)
		$hbox.add_child(heroButton)
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text
	$field_sc.text = str(data.lootWon.questPrizeSC) + " coins" #set in global when the quest timer expires
	$field_hc.text = str(data.lootWon.questPrizeHC) + " diamonds"
	if (data.lootWon.questPrizeItem1):
		$field_lootName1.text = data.lootWon.questPrizeItem1
	if (data.lootWon.questPrizeItem2):
		$field_lootName2.text = data.lootWon.questPrizeItem2

func _on_button_collectRewards_pressed():
	print("COLLECTING PRIZES AND GOING BACK TO MAIN")
	#COLLECT coins, xp, inventory items into player's real inventory
	global.softCurrency += currentQuest.lootWon.questPrizeSC
	global.hardCurrency += currentQuest.lootWon.questPrizeHC
	#we have the item's name, now get its actual entity and give it to the guildItems array
	if (currentQuest.lootWon.questPrizeItem1):
		#todo: make sure the vault has room for it first 
		#todo: this method should be global because the same logic is used in popup_itemInfo.gd
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[currentQuest.lootWon.questPrizeItem1]
				break
		
	if (currentQuest.lootWon.questPrizeItem2):
		#global.guildItems.append(global.allGameItems[currentQuest.lootWon.questPrizeItem2])
		#todo: make sure the vault has room for it first 
		#todo: this method should be global because the same logic is used in popup_itemInfo.gd
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[currentQuest.lootWon.questPrizeItem2]
				break
	
	#give xp to each hero in quest list, set status back to available, clear them out of the quest array
	for i in range(currentQuest.heroes.size()):
		if (currentQuest.heroes[i] != null):
			currentQuest.heroes[i].xp += currentQuest.xp
			#if there's xp overflow, set xp to level total 
			if (currentQuest.heroes[i].xp > global.levelXpData[currentQuest.heroes[i].level].total):
				currentQuest.heroes[i].xp = global.levelXpData[currentQuest.heroes[i].level].total
			currentQuest.heroes[i].atHome = true
			currentQuest.heroes[i].staffedTo = ""
			currentQuest.heroes[i] = null
			#global.questHeroesPicked -= 1
	
	currentQuest.lootWon.questPrizeItem1 = null
	currentQuest.lootWon.questPrizeItem2 = null
	currentQuest.readyToCollect = false
	get_tree().change_scene("res://main.tscn")
	
func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
