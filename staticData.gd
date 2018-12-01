extends Node
#staticData.gd

#Things that belong in this file:
#dictionaries and arrays of data that do not vary by player/save 
#the methods that load that data in on init 
#constants like menu colors 

#Filereading
var unformattedData = null

#dictionaries of all the game's items, quests, mobs, etc 
var allItemData = {} #staticData.allGameItemData["Item Name"]
var allMobData = {}  #staticData.allMobData["mobName"]
var allLootTableData = {} #staticData.allLootTableData["lootTable"]
var allRecipeData = {} #staticData.allRecipeData["recipeName"]
var allQuestData = {} #staticData.allGameQuestData["questId"]

var allRoomTypeData = null
var allLevelXpData = null 
var allHeroStartingStatData = null

#names
var humanMaleNames = []
var humanFemaleNames = []
var surnamesHuman = []
var surnamesNature = []
var surnamesRogue = []
var surnamesWizard = []
var surnamesWarrior = []
var surnamesCleric = []

var colorGreen = Color(.062, .90, .054, 1) #16,230,14 green
var colorBlue = Color(.070, .313, .945, 1) #18,80,241 blue
var colorPink = Color(.945, .070, .525, 1) #241,18,134 pink
var colorWhite = Color(1, 1, 1, 1) #white
var colorYellow = Color(.93, .913, .25, 1) #yellow

func _ready():
	pass
	
func _load_static_data():
	#Prepare to load game data. These use unformattedData
	var key = null #a string, ie: "Tadloc Grunt"
	var value = null #another dictionary, ie: {dps:4, str:5}
	
	###### Load item data ######
	unformattedData = util.prepare_unformatted_data_from_file("items.json")
	#Access like: var item = global.allGameItems("Rusty Broadsword")
	
	for item in unformattedData:
		if (item):
			key = item["name"] #a string, ie: "Rusty Broadsword"
			value = item #another dictionary, ie: {dps:4, str:5}
			value["itemID"] = -1 #ID isn't assigned until we actually give this item to the guild or a hero
			value["improved"] = false
			value["improvement"] = ""
			allItemData[key] = value
		
			#if it's a tradeskill item, put it in the tradeskill items dictionary
			if (value["itemType"] == "tradeskill"):
				global.playerTradeskillItems[key] = {
					"count": 0,
					"name":key,
					"icon":value.icon,
					"seen":false,
					"consumable":value.consumable
					}
			elif (value["itemType"] == "quest"): #or put it in the quest items dictionary
				global.playerQuestItems[key] = {
					"count":0,
					"name":key,
					"icon":value.icon,
					"seen":false,
					"consumable":value.consumable
					}
			else:	
				var classRestrictionsArray = []
				classRestrictionsArray.append(allItemData[key].classRestriction1)
				if (allItemData[key].classRestriction2 != ""):
					classRestrictionsArray.append(allItemData[key].classRestriction2)
				if (allItemData[key].classRestriction3 != ""):
					classRestrictionsArray.append(allItemData[key].classRestriction3)
				if (allItemData[key].classRestriction4 != ""):
					classRestrictionsArray.append(allItemData[key].classRestriction4)
				if (allItemData[key].classRestriction5 != ""):
					classRestrictionsArray.append(allItemData[key].classRestriction5)
				
				allItemData[key].classRestrictions = classRestrictionsArray
	
	###### Load mob data ######
	#(mobs are a lot like items, they have names and stats and we access them by their name)
	#but we don't need instances of them like we do heroes, they don't really persist the way heroes do
	unformattedData = util.prepare_unformatted_data_from_file("mobs.json")
	for mob in unformattedData:
		if (mob):
			key = mob["mobName"]
			value = mob
			#add anything else to mobValue here, ie: mobValue["someNewStatNotInData"] = 5
			value.hpCurrent = int(value.hp)
			value.manaCurrent = int(value.mana)
			value.dead = false
			allMobData[key] = value
			
	###### Load loot table data ######
	unformattedData = util.prepare_unformatted_data_from_file("lootTables.json")
	for lootTable in unformattedData:
		if (lootTable):
			key = lootTable["lootTableName"] #key: a string, ie: ratLoot01
			value = lootTable  #value: another dictionary, ie: {item1: itemname, item1Chance: 20}
			#add anything else to value here, 
			allLootTableData[key] = value
	
	###### Load quest data ######
	unformattedData = util.prepare_unformatted_data_from_file("quests.json")
	#Access quests by id, ie: "forest01"
	for quest in unformattedData:
		key = quest["questId"] #a string, ie: "forest01"
		value = quest #another dictionary, ie: {prize1:"prize name", heroes:3}
		value.timesRun = 0
		#loot won is filled in when the quest is completed and held in the object until collected, then it is nulled out for re-use
		allQuestData[key] = value
		
	###### Load tradeskill crafting recipes ######
	unformattedData = util.prepare_unformatted_data_from_file("recipes.json")
	
	#first, make every recipe into an object with the recipe name as the key and all the data as the value
	for recipe in unformattedData:
		key = recipe["recipeName"]  #a string, ie: "Sharpening Stone"
		value = recipe #another dictionary, ie: {name:"name", ingredient1:"some thing"}
		#add this data to the key in allRecipeData
		allRecipeData[key] = value
		
		#second, append each recipe into the array that we'll access them from elsewhere in the game
		#this syntax is like: tradeskills["blacksmithing"].recipes.append(...)
		
		global.tradeskills[recipe.tradeskill].recipes.append(allRecipeData[key])
		
	#set a default recipe for each tradeskill
	if (!global.tradeskills["alchemy"].selectedRecipe):
		global.tradeskills["alchemy"].selectedRecipe = global.tradeskills.alchemy.recipes[0]
	
	if (!global.tradeskills["blacksmithing"].selectedRecipe):
		global.tradeskills["blacksmithing"].selectedRecipe = global.tradeskills.blacksmithing.recipes[0]
	
	if (!global.tradeskills["fletching"].selectedRecipe):
		global.tradeskills["fletching"].selectedRecipe = global.tradeskills.fletching.recipes[0]
			
	if (!global.tradeskills["jewelcraft"].selectedRecipe):
		global.tradeskills["jewelcraft"].selectedRecipe = global.tradeskills.jewelcraft.recipes[0]

	if (!global.tradeskills["tailoring"].selectedRecipe):
		global.tradeskills["tailoring"].selectedRecipe = global.tradeskills.tailoring.recipes[0]
		
	###### Load room type data ######
	allRoomTypeData = util.prepare_unformatted_data_from_file("roomTypes.json")
	
	###### Load hero level data ######
	allLevelXpData = util.prepare_unformatted_data_from_file("levelXpData.json")
	
	###### Load hero stat data ######
	#access an individual class's stats like this: 
	#print(str(heroStartingStatData[0]["rogue"]["defense"]))
	unformattedData = util.prepare_unformatted_data_from_file("heroStats.json")
	allHeroStartingStatData = unformattedData[0]
	
	###### Load hero names ######
	humanMaleNames = util.prepare_unformatted_data_from_file("names/humanMale.json")
	humanFemaleNames = util.prepare_unformatted_data_from_file("names/humanFemale.json")
	surnamesHuman = util.prepare_unformatted_data_from_file("names/surnamesHuman.json")
	surnamesNature = util.prepare_unformatted_data_from_file("names/surnamesNature.json")
	surnamesRogue = util.prepare_unformatted_data_from_file("names/surnamesRogue.json")
	surnamesWizard = util.prepare_unformatted_data_from_file("names/surnamesWizard.json")
	surnamesWarrior = util.prepare_unformatted_data_from_file("names/surnamesWarrior.json")
	surnamesCleric = util.prepare_unformatted_data_from_file("names/surnamesCleric.json")
			