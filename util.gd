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

func determine_if_skill_up_happens(heroSkillLevel, trivialLevel): #pass current skill, pass trivial level
	var skillUpHappened = false
	#only attempt to skill up if the recipe trivial is higher than current skill level 
	if (heroSkillLevel < trivialLevel):
		#just a 50/50 chance for now
		var skillUpRandom = randi()%2+1 #1-2
		if (skillUpRandom == 2):
			skillUpHappened = true
	
	return skillUpHappened
	
#check out hero.gd for give_item to a hero 
func give_item_guild(itemName): #itemName comes in as a string 
	if (staticData.items[itemName] && staticData.items[itemName].itemType == "tradeskill"):
		if (!global.playerTradeskillItems[itemName].seen):
			# might be this now: global.playerTradeskillItems
			global.tradeskillItemsSeen.append(itemName)
			global.playerTradeskillItems[itemName].seen = true
		#either way, increase the count
		global.playerTradeskillItems[itemName].count += 1
	elif (staticData.items[itemName] && staticData.items[itemName].itemType == "quest"):
		if (!global.playerQuestItems[itemName].seen):
			global.questItemsSeen.append(itemName)
			global.playerQuestItems[itemName].seen = true
		#either way, increase the count
		global.playerQuestItems[itemName].count += 1
	else:
		#make sure this item actually exists in the item records
		if (!staticData.items[itemName]):
			print("ERROR! Make sure this item name exists: " + itemName)
		#finds first open null spot and puts the item there
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				global.guildItems[i] = staticData.items[itemName].duplicate() #make a new instance
				global.guildItems[i].itemID = global.nextItemID
				global.nextItemID += 1
				break
	
	
func give_modded_item_guild(itemName, tradeskill, stat, bonusAmount): #itemName comes in as a string 
	print("giving a modded item to the guild")
	var moddedItem = global.tradeskills[tradeskill].currentlyCrafting.wildcardItem
	moddedItem[stat] += bonusAmount
	moddedItem["improved"] = true
	moddedItem["improvement"] = "(+" + str(bonusAmount) + " " + stat + ")"
	moddedItem.name = "Improved " + moddedItem.name
	
	#finds first open null spot and moves the item from the tradeskill bucket back into the array
	for i in range(global.guildItems.size()):
		if (global.guildItems[i] == null):
			global.guildItems[i] = moddedItem
			break
		
		
func remove_item_guild_by_name(itemNameStr):
	#remove first usage of this item by name
	var removeIdx = global.guildItems.find(itemNameStr)
	if (removeIdx):
		global.guildItems.remove(removeIdx)
					
func remove_item_guild_by_id(itemID):
	print("util.gd: Removing itemID " + str(itemID) + " from guild's inventory")
	#delete it by nulling its index
	for i in range(global.guildItems.size()):
		if (global.guildItems[i]):
			if (global.guildItems[i].itemID == itemID): 
				global.guildItems[i] = null
	
func give_item_tradeskill(itemID):
	#we have the item ID, which we can find in the guildItems array
	print("util.gd: Giving itemID " + str(itemID) + " to tradeskill.wildcardItemOnDeck")
	for i in range(global.guildItems.size()):
		if (global.guildItems[i]):
			if (global.guildItems[i].itemID == itemID):
				#we found the item with the matching ID
				global.tradeskills[global.currentMenu].wildcardItemOnDeck = global.guildItems[i].duplicate()
				#remove from guildItems (because the tradeskill will hold it for now)
				global.guildItems[i] = null
	
func remove_item_tradeskill():
	#finds first open null spot and moves the item from the tradeskill bucket back into the array
	for i in range(global.guildItems.size()):
		if (global.guildItems[i] == null):
			global.guildItems[i] = global.tradeskills[global.currentMenu].wildcardItemOnDeck
			break
	#empties the wildcardItemOnDeck bucket 
	global.tradeskills[global.currentMenu].wildcardItemOnDeck = null
	
func give_quest(questID):
	var newQuestInstance = staticData.quests[questID].duplicate()
	global.activeQuests.append(newQuestInstance)
	