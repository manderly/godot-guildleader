extends Node
#util.gd 

func _ready():
	pass

func prepare_unformatted_data_from_file(filenameStr):
	var dataFile = File.new()
	dataFile.open("res://gameData/"+filenameStr, dataFile.READ)
	var unformattedData = parse_json(dataFile.get_as_text())
	dataFile.close()
	return unformattedData
	
#use: util.format_time(timeData) 
func format_time(time):
	var timeFormattedForDisplay = null
	if (time > 3599):
		timeFormattedForDisplay = str(round(time / 3600)) + "h"
	elif (time > 59):
		timeFormattedForDisplay = str(round(time / 60)) + "m"
	else:
		timeFormattedForDisplay = str(round(time)) + "s"
		
	return timeFormattedForDisplay

func get_hero_by_id(id):
	for i in range(global.guildRoster.size()):
		if (global.guildRoster[i].heroID == id):
			return global.guildRoster[i]
	print("util.gd error: hero with ID " + str(id) + " not found") 
	
func getRecipeDifficulty(trivial, crafterSkill):
	# returns one of the following: "trivial", "white", "yellow", "red"
	# [trivial][white][yellow][red    ]
	var ret = "unknown"
	if (trivial <= crafterSkill):
		ret = "trivial"
	elif (trivial > crafterSkill):
		# this item is greater than the hero's skill but...
		if (trivial <= crafterSkill + 6):
			# between current skill and current skill + 6
			ret = "white"
		elif (trivial > crafterSkill + 6 and trivial < crafterSkill + 16):
			# between current skill + 7 and current skill + 11
			ret = "yellow"
		elif (trivial >= crafterSkill + 16):
			ret = "red"
	return ret
	
	
func determine_if_skill_up_happens(heroSkillLevel, trivialLevel): #pass current skill, pass trivial level
	var skillUpHappened = false
	#only attempt to skill up if the recipe trivial is higher than current skill level 
	# red = guaranteed, 100% 
	# yellow = 50% chance
	# white = 25% chance
	# gray = 0% chance
	var difficulty = getRecipeDifficulty(trivialLevel, heroSkillLevel)
	if (difficulty == "red"):
		skillUpHappened = true
	elif (difficulty == "yellow"):
		var skillUpRandom = randi()%2+1 #1-2
		if (skillUpRandom == 1): # a 1/2 chance of skilling up on yellow
			skillUpHappened = true
	elif (difficulty == "white"):
		var skillUpRandom = randi()%4+1 #1-4
		if (skillUpRandom == 2): # a 1/4 chance of skilling up on white 
			skillUpHappened = true
	elif (difficulty == "trivial"):
		skillUpHappened = false
	else:
		print("Unknown difficulty score - line 66 of util.gd")
	return skillUpHappened
	
# items from the vault are identified by their index
func transfer_item_from_vault_to_bedroom(vaultIndex):
	var vaultItem = global.vault.peek_item(vaultIndex)
	var slot = vaultItem.slot
	if (slot == "bed"):
		# expand it back out to which bed, specifically
		slot = global.whichBed
	global.bedrooms[global.selectedBedroom]["inventory"][slot] = vaultItem
	global.vault.delete_item(vaultIndex) #null it out of the vault, it's now on the hero
	
func transfer_item_from_bedroom_to_vault(item):
	if (global.vault.has_room()):
		global.vault.give_item(item)
		var slot = item.slot
		if (slot == "bed" || slot == "bed"):
			slot = global.whichBed
		global.bedrooms[global.selectedBedroom]["inventory"][slot] = null
	else:
		print("util.gd: No Room in vault!")
	
func transfer_item_from_hero_equip_to_vault(item): 
	# verify there is room in the vault
	if (global.vault.has_room()):
		# give the item to the guild inventory
		global.vault.give_item(item)
		# null it out from the hero's equipment slot  
		global.selectedHero["equipment"][item.slot] = null
		global.selectedHero.update_hero_stats() #recalculate hero stats
	else:
		print("util.gd: No Room in vault!")

func transfer_item_from_vault_to_hero_equip(vaultIndex):
	var vaultItem = global.vault.peek_item(vaultIndex)
	global.selectedHero.give_existing_item(vaultItem)
	global.vault.delete_item(vaultIndex) #null it out of the vault, it's now on the hero
	global.selectedHero.update_hero_stats() #recalculate hero stats

#check out hero.gd for give_item to a hero 
func give_new_item_guild(itemName, quantity): #itemName comes in as a string
	if (staticData.items.has(itemName)):
		var newItem = staticData.items[itemName]
		for i in range(quantity):
			if (newItem.itemType == "tradeskill"):
				if (!global.playerTradeskillItems[itemName].seen):
					global.tradeskillItemsSeen.append(itemName)
					global.playerTradeskillItems[itemName].seen = true
				#either way, increase the count
				global.playerTradeskillItems[itemName].count += 1
			elif (newItem.itemType == "quest"):
				if (!global.playerQuestItems[itemName].seen):
					global.questItemsSeen.append(itemName)
					global.playerQuestItems[itemName].seen = true
				#either way, increase the count
				global.playerQuestItems[itemName].count += 1
			else:
				# non-stackable array-inventory item 
				global.vault.give_new_item(itemName, quantity)
	else:
		print("util.gd error: item [" + itemName + "] not found in staticData.items")
	
func give_modded_item_guild(itemName, tradeskill, stat, bonusAmount): #itemName comes in as a string 
	var moddedItem = global.tradeskills[tradeskill].currentlyCrafting.wildcardItem
	moddedItem[stat] += bonusAmount
	moddedItem["improved"] = true
	moddedItem["improvement"] = "(+" + str(bonusAmount) + " " + stat + ")"
	moddedItem.name = "Improved " + moddedItem.name
	
	global.vault.give_item(moddedItem)
	#finds first open null spot and moves the item from the tradeskill bucket back into the array
	
func give_item_tradeskill(itemID):
	#we have the item ID, which we can find in the guildItems array
	#print("util.gd: Giving itemID " + str(itemID) + " to tradeskill.wildcardItemOnDeck")
	for i in range(global.vault.size()):
		var item = global.vault.peek_item(i)
		if (item):
			if (item.itemID == itemID):
				#we found the item with the matching ID
				global.tradeskills[global.currentMenu].wildcardItemOnDeck = item # was .duplicate()
				#remove from guildItems (because the tradeskill will hold it for now)
				global.vault.delete_item(i)
	
func remove_item_tradeskill():
	#finds first open null spot and moves the item from the tradeskill bucket back into the array
	var giveMeBack = global.tradeskills[global.currentMenu].wildcardItemOnDeck
	global.vault.give_item(giveMeBack)
	#empties the wildcardItemOnDeck bucket 
	global.tradeskills[global.currentMenu].wildcardItemOnDeck = null
	
func give_quest(questID):
	var newQuestInstance = staticData.quests[questID].duplicate()
	global.activeQuests.append(newQuestInstance)
	
func calc_instant_train_cost():	
	#1/1/19 redo: now it just takes the cost from the levelXpData data, for better control over it
	var cost = 999
	if (global.selectedHero.level >= 30):
		cost = 30
	else:
		cost = staticData.levelXpData[str(global.selectedHero.level+1)].chronoCost
	
	return cost