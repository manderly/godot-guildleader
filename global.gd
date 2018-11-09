#global.gd 

#todo: localization support
# [{'EN': {'craftingButtonText': 'Crafting'}}, {'JP': {'craftingButtonText': 'Tsukurimono'}} 

extends Node
var nameGenerator = load("res://nameGenerator.gd").new()
var mobGenerator = load("res://mobGenerator.gd").new()
var encounterGenerator = load("res://encounterGenerator.gd").new()

var softCurrency = 500
var hardCurrency = 500
var currentMenu = "main"
var vaultSpace = 25 #should be a multiple of 5
var guildName = "" 

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage
var guildRoster = []
var guildCapacity = 4 #each bedroom adds +2 capacity 

var unrecruited = []

#Mobs
var unformattedMobData = null
var mobData = {}

#Loot tables
var unformattedLootTablesData = null
var lootTables = {}

#Quests
var unformattedQuestData = null
var questData = {}
var allGameQuests = {}
var activeQuests = []
var selectedQuestID = ""

#active quest
var questButtonID = null
var levelXpData = null #from json 
var heroStartingStatData = null #from json

#Harvesting (resource nodes placed on maps)
var unformattedHarvestingData = null
var harvestingData = {}
var selectedHarvestingID = null

#Camps
var unformattedCampData = null
var campData = {}

var campButtonID = null
var selectedCampID = null #used by quest confirm to pass data to correct quest sub-object in questData object

var currentCamp = null

var roomTypeData = null
var itemData = null
var nextItemID = 100

var initDone = false

#rooms
onready var rooms = []
onready var roomCount = 0
var newRoomCost = [10, 20, 30, 50, 70, 80, 90, 100, 1000, 1000, 1000, 1000, 1000, 1000]
var tradeskillRoomsToBuild = ["blacksmith", "alchemy", "fletching", "jewelcraft", "tailoring"] #remove from array as they are built 

#tradeskill flags
#use: global.tradeskills[global.currentMenu] 
#example: global.tradeskills["alchemy"].hero
var tradeskills = {
	"alchemy": {
		"hero": null,
		"timer": null,
		"inProgress": false,
		"readyToCollect": false,
		"wildcardItem": null,
		"displayName": "Alchemy",
		"description": "Potions and stuff",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"name":"",
			"statImproved":"",
			"statIncrease":"",
			"totalTimeToFinish":""
		}
	},
	"blacksmithing": {
		"hero": null,
		"timer": null,
		"inProgress": false,
		"readyToCollect": false,
		"wildcardItem": null,
		"displayName": "Blacksmithing",
		"description": "Combine fire and metal to craft weapons and armor from ore, metals, and other materials.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"name":"",
			"statImproved":"",
			"statIncrease":"",
			"totalTimeToFinish":""
		}
	},
	"fletching": {
		"hero": null,
		"timer": null,
		"inProgress": false,
		"readyToCollect": false,
		"wildcardItem": null,
		"displayName": "Fletching",
		"description":"Make arrows and bows",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"name":"",
			"statImproved":"",
			"statIncrease":"",
			"totalTimeToFinish":""
		}
	},
	"jewelcraft": {
		"hero": null,
		"timer": null,
		"inProgress": false,
		"readyToCollect": false,
		"wildcardItem": null,
		"displayName": "Jewelcraft",
		"description":"Bend metal and gemstones into sparkly jewelry with powerful stat bonuses.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"name":"",
			"statImproved":"",
			"statIncrease":"",
			"totalTimeToFinish":""
		}
	},
	"tailoring": {
		"hero": null,
		"timer": null,
		"inProgress": false,
		"readyToCollect": false,
		"wildcardItem": null,
		"displayName": "Tailoring",
		"description":"Turn cloth and leather into useful items, such as robes, vests, and padding for plate armor made by blacksmiths.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"name":"",
			"statImproved":"",
			"statIncrease":"",
			"totalTimeToFinish":""
		}
	}
}

#the x min and max is the same for all rooms
var roomMinX = 200
var roomMaxX = 360

#names
var humanMaleNames = []
var humanFemaleNames = []

#signal quest_begun
signal quest_complete

#items inventory / vault
var allGameItems = {}
var guildItems = []
var tradeskillItemsSeen = [] #keep track of all the tradeskill items we've encountered, never remove
var tradeskillItemsDictionary = {} #keep count of tradeskill items and their counts here
var questItemsSeen = [] #keep track of all the quest items we've encountered, todo: player can remove
var questItemsDictionary = {} #keep count of quest items and their counts here
var swapItemSourceIdx = null
var inSwapItemState = false
var lastItemButtonClicked = null
var filterVaultByItemSlot = null
var browsingForSlot = ""
var browsingForType = ""

var recipesFile = null
var recipesData = null #raw json parse 
var recipeKey = null
var recipeValue = null
var allRecipes = {}

var colorGreen = Color(.062, .90, .054, 1) #16,230,14 green
var colorBlue = Color(.070, .313, .945, 1) #18,80,241 blue
var colorPink = Color(.945, .070, .525, 1) #241,18,134 pink
var colorWhite = Color(1, 1, 1, 1) #white
var colorYellow = Color(.93, .913, .25, 1) #yellow

func _ready():
	randomize()
	
	#Name the guild!
	global.guildName = nameGenerator.generateGuildName()
	
	#Load mob data (mobs are a lot like items, they have names and stats and we access them by their name)
	#but we don't need instances of them like we do heroes, they don't really persist the way heroes do
	var mobsFile = File.new()
	mobsFile.open("res://gameData/mobs.json", mobsFile.READ)
	unformattedMobData = parse_json(mobsFile.get_as_text())
	mobsFile.close()
	var mobKey = null #a string, ie: "Tadloc Grunt"
	var mobValue = null #another dictionary, ie: {dps:4, str:5}

	for mob in unformattedMobData:
		if (mob):
			mobKey = mob["mobName"]
			mobValue = mob
			#add anything else to mobValue here, ie: mobValue["someNewStatNotInData"] = 5
			mobValue.hpCurrent = mobValue.hp
			mobValue.manaCurrent = mobValue.mana
			mobValue.dead = false
			global.mobData[mobKey] = mobValue
			
	
	#Load loot table data
	var lootTablesFile = File.new()
	lootTablesFile.open("res://gameData/lootTables.json", lootTablesFile.READ)
	unformattedLootTablesData = parse_json(lootTablesFile.get_as_text())
	lootTablesFile.close()
	var lootTableKey = null #a string, ie: ratLoot01
	var lootTableValue = null #another dictionary, ie: {item1: itemname, item1Chance: 20}
	
	for lootTable in unformattedLootTablesData:
		if (lootTable):
			lootTableKey = lootTable["lootTableName"]
			lootTableValue = lootTable
			#add anything else to lootTableValue here, 
			global.lootTables[lootTableKey] = lootTableValue
	
	#Load quest data
	var questFile = File.new()
	questFile.open("res://gameData/quests.json", questFile.READ)
	var unformattedQuestData = parse_json(questFile.get_as_text())
	questFile.close()
	
	#so we can access quests by ID 
	var questKey = null #a string, ie: "forest01"
	var questValue = null #another dictionary, ie: {prize1:"prize name", heroes:3}
	for quest in unformattedQuestData:
		questKey = quest["questId"]
		questValue = quest
		questValue.timesRun = 0
		#loot won is filled in when the quest is completed and held in the object until collected, then it is nulled out for re-use
		global.allGameQuests[questKey] = questValue
	#now we have all the quest data as a dictionary
	#give quests to the player like if they were items
	util.give_quest("test09")
	util.give_quest("test10")
	util.give_quest("azuricite_quest01")
	global.selectedQuestID = "test09"
	
	#Load harvesting data (structurally similar to how Quests used to work)
	var harvestingFile = File.new()
	harvestingFile.open("res://gameData/harvesting.json", harvestingFile.READ)
	var unformattedHarvestingData = parse_json(harvestingFile.get_as_text())
	harvestingFile.close()
	
	#so we can access harvesting by ID 
	var harvestingKey = null #a string, ie: "harvesting_copperOre"
	var harvestingValue = null #another dictionary, ie: {prize1:"prize name", heroes:3}
	for data in unformattedHarvestingData:
		harvestingKey = data["harvestingId"]
		harvestingValue = data
		harvestingValue.hero = null
		harvestingValue.timer = null
		harvestingValue.inProgress = false
		harvestingValue.readyToCollect = false
		harvestingValue.timesRun = 0
		harvestingValue.lootWon = {
			"prizeItem1":null,
			"prizeQuantity":0
		}
		global.harvestingData[harvestingKey] = harvestingValue
	
	#Load camp data
	var campFile = File.new()
	campFile.open("res://gameData/camps.json", campFile.READ)
	var unformattedCampData = parse_json(campFile.get_as_text())
	campFile.close()
	
	#now reformat so we can access camps by ID
	var campKey = null
	var campValue = null #another dictionary, ie: {prize1:"prize name", heroes:3}
	for data in unformattedCampData:
		campKey = data["campId"]
		campValue = data
		campValue.heroes = [null, null, null, null] #hardcode to 4 for now?
		campValue.mobs = []
		if (campValue.mob1):
			campValue.mobs.append(mobGenerator.get_mob(campValue.mob1))
		if (campValue.mob2):
			campValue.mobs.append(mobGenerator.get_mob(campValue.mob2))
		if (campValue.mob3):
			campValue.mobs.append(mobGenerator.get_mob(campValue.mob3))
		campValue.timer = null
		campValue.inProgress = false
		campValue.readyToCollect = false
		campValue.timesRun = 0
		campValue.campHeroesSelected = 0
		campValue.selectedDuration = 0
		campValue.enableButton = ""
		campValue.campOutcome = {}
		#to set a camp: global.currentCamp = global.campData["camp_forest01"]
		global.campData[campKey] = campValue
	
	#Load room type data and save it to a global var
	var roomTypeFile = File.new()
	roomTypeFile.open("res://gameData/roomTypes.json", roomTypeFile.READ)
	roomTypeData = parse_json(roomTypeFile.get_as_text())
	roomTypeFile.close()
	
	#Load hero level data 
	var levelXpFile = File.new()
	levelXpFile.open("res://gameData/levelXpData.json", levelXpFile.READ)
	levelXpData = parse_json(levelXpFile.get_as_text())
	levelXpFile.close()
	
	#Load hero stat data
	var heroStatsFile = File.new()
	heroStatsFile.open("res://gameData/heroStats.json", heroStatsFile.READ)
	heroStartingStatData = parse_json(heroStatsFile.get_as_text())
	heroStatsFile.close()
	heroStartingStatData = heroStartingStatData[0]
	#print(heroStatData)
	#access an individual class's stats like this: 
	#print(str(heroStartingStatData[0].rogue)) 
	#print(str(heroStartingStatData[0]["rogue"]["defense"]))
	
	#load names
	var humanMaleNamesFile = File.new()
	humanMaleNamesFile.open("res://gameData/names/humanMale.json", humanMaleNamesFile.READ)
	humanMaleNames = parse_json(humanMaleNamesFile.get_as_text())
	humanMaleNamesFile.close()
	
	var humanFemaleNamesFile = File.new()
	humanFemaleNamesFile.open("res://gameData/names/humanFemale.json", humanFemaleNamesFile.READ)
	humanFemaleNames = parse_json(humanFemaleNamesFile.get_as_text())
	humanFemaleNamesFile.close()
	
	#Load game item data
	var itemsFile = File.new()
	itemsFile.open("res://gameData/items.json", itemsFile.READ)
	itemData = parse_json(itemsFile.get_as_text())
	itemsFile.close()
	var itemKey = null #a string, ie: "Rusty Broadsword"
	var itemValue = null #another dictionary, ie: {dps:4, str:5}
	
	#want to be able to access like: 
	#var item = find("Rusty Broadsword")
	#then access stats like: item.dps, item.str etc by name 
	#["Rusty Broadsword"]["dps"]
	
	for i in range(itemData.size()):
		itemKey = itemData[i]["name"]
		itemValue = itemData[i]
		itemValue["itemID"] = -1 #ID isn't assigned until we actually give this item to the guild or a hero
		itemValue["improved"] = false
		itemValue["improvement"] = ""
		global.allGameItems[itemKey] = itemValue
		
		#if it's a tradeskill item, put it in the tradeskill items dictionary
		if (itemValue["itemType"] == "tradeskill"):
			tradeskillItemsDictionary[itemKey] = {
				"count": 0,
				"name":itemKey,
				"icon":itemValue.icon,
				"seen":false,
				"consumable":itemValue.consumable
				}
		elif (itemValue["itemType"] == "quest"): #or put it in the quest items dictionary
			questItemsDictionary[itemKey] = {
				"count":0,
				"name":itemKey,
				"icon":itemValue.icon,
				"seen":false,
				"consumable":itemValue.consumable
				}
		else:	
			#do class restrictions 
			var classRestrictionsArray = []
			classRestrictionsArray.append(global.allGameItems[itemKey].classRestriction1)
			if (global.allGameItems[itemKey].classRestriction2 != ""):
				classRestrictionsArray.append(global.allGameItems[itemKey].classRestriction2)
			if (global.allGameItems[itemKey].classRestriction3 != ""):
				classRestrictionsArray.append(global.allGameItems[itemKey].classRestriction3)
			if (global.allGameItems[itemKey].classRestriction4 != ""):
				classRestrictionsArray.append(global.allGameItems[itemKey].classRestriction4)
			if (global.allGameItems[itemKey].classRestriction5 != ""):
				classRestrictionsArray.append(global.allGameItems[itemKey].classRestriction5)
			
			global.allGameItems[itemKey].classRestrictions = classRestrictionsArray
	
	#since we can't init the guildItems array to the size of the vault...
	global.guildItems.resize(vaultSpace)
	
	#for now, start the user off with some items (visible in the vault)
	util.give_item_guild("Rusty Broadsword")
	util.give_item_guild("Novice's Blade")
	util.give_item_guild("Novice's Blade")
	#here's some uber loot for testing purposes 
	util.give_item_guild("Basic Bow")
	util.give_item_guild("Simple Ring")
	util.give_item_guild("Crimson Staff")
	util.give_item_guild("Staff of the Four Winds")
	util.give_item_guild("Obsidian Quickblade")
	util.give_item_guild("Robe of Alexandra")
	util.give_item_guild("Sparkling Metallic Robe")
	util.give_item_guild("Robe of the Dunes")
	util.give_item_guild("Prestige Robe")
	util.give_item_guild("Softscale Boots")
	util.give_item_guild("Seer's Orb")
	util.give_item_guild("Bladestorm")
	util.give_item_guild("Bladestorm")
	
	util.give_item_guild("Scepter of the Child King")
	util.give_item_guild("Rough Stone")
	util.give_item_guild("Rough Stone")
	util.give_item_guild("Leather Strip")
	util.give_item_guild("Small Brick of Ore")
	util.give_item_guild("Copper Ore")
	
	#load tradeskill crafting recipes
	recipesFile = File.new()
	recipesFile.open("res://gameData/recipes.json", recipesFile.READ)
	recipesData = parse_json(recipesFile.get_as_text())
	recipesFile.close()
	
	recipeKey = null #a string, ie: "Sharpening Stone"
	recipeValue = null #another dictionary, ie: {name:"name", ingredient1:"some thing"}
	
	#want to be able to access like: 
	#var recipe = find("Sharpening Stone")
	#then access stats like: item.dps, item.str etc by name 
	#["Sharpening Stone"]["ingredient1"]
	
	#first, make every recipe into an object with the recipe name as the key and all the data as the value
	for i in range(recipesData.size()):
		recipeKey = recipesData[i]["recipeName"]
		recipeValue = recipesData[i]
		#add this data to the key in allRecipes
		allRecipes[recipeKey] = recipeValue
		#second, append each recipe into the array that we'll access them from elsewhere in the game
		#this syntax is like: tradeskills["blacksmithing"].recipes.append(...)
		tradeskills[recipesData[i].tradeskill].recipes.append(allRecipes[recipeKey])
		
	#set a default recipe for each tradeskill
	if (!global.tradeskills["alchemy"].selectedRecipe):
		global.tradeskills["alchemy"].selectedRecipe = tradeskills.alchemy.recipes[0]
	
	if (!global.tradeskills["blacksmithing"].selectedRecipe):
		global.tradeskills["blacksmithing"].selectedRecipe = tradeskills.blacksmithing.recipes[0]
	
	if (!global.tradeskills["fletching"].selectedRecipe):
		global.tradeskills["fletching"].selectedRecipe = tradeskills.fletching.recipes[0]
			
	if (!global.tradeskills["jewelcraft"].selectedRecipe):
		global.tradeskills["jewelcraft"].selectedRecipe = tradeskills.jewelcraft.recipes[0]

	if (!global.tradeskills["tailoring"].selectedRecipe):
		global.tradeskills["tailoring"].selectedRecipe = tradeskills.tailoring.recipes[0]
		

		
func _begin_global_quest_timer(duration, questID):
	#starting quest timer 
	var quest = global.questData[questID]
	if (!quest.inProgress):
		quest.inProgress = true
		quest.readyToCollect = false
		quest.timer = Timer.new()
		quest.timer.set_one_shot(true)
		quest.timer.set_wait_time(duration)
		quest.timer.connect("timeout", self, "_on_questTimer_timeout", [questID])
		quest.timer.start()
		add_child(quest.timer)
	else:
		print("error: quest already running")
		
func _begin_harvesting_timer(duration, harvestNodeID):
	#starting harvest timer 
	var harvestNode = global.harvestingData[harvestNodeID]
	if (!harvestNode.inProgress):
		harvestNode.inProgress = true
		harvestNode.readyToCollect = false
		harvestNode.timer = Timer.new()
		harvestNode.timer.set_one_shot(true)
		harvestNode.timer.set_wait_time(duration)
		harvestNode.timer.connect("timeout", self, "_on_harvestingTimer_timeout", [harvestNodeID])
		harvestNode.timer.start()
		add_child(harvestNode.timer)
	else:
		print("error: harvestNode already running")
		
func _on_harvestingTimer_timeout(harvestNodeID):
	#this is where the harvest's random prizes are determined 
	global.logger(self, "Harvest timer complete! Finished this harvest: " + harvestNodeID)
	var harvestNode = global.harvestingData[harvestNodeID]
	harvestNode.readyToCollect = true
	harvestNode.harvestPrizeQuantity = round(rand_range(harvestNode.minQuantity, harvestNode.maxQuantity))
	#emit_signal("harvesting_complete", harvestNode.prizeItem1)

func _begin_camp_timer(duration, campID):
	print("starting camp timer")
	#starting camp timer 
	var camp = global.campData[campID]
	if (!camp.inProgress):
		camp.inProgress = true
		camp.readyToCollect = false
		camp.timer = Timer.new()
		camp.timer.set_one_shot(true)
		camp.timer.set_wait_time(duration)
		camp.timer.connect("timeout", self, "_on_campTimer_timeout", [campID])
		camp.timer.start()
		add_child(camp.timer) 
	else:
		print("error: camp already running")

func _on_campTimer_timeout(campID):
	global.logger(self, "Camp timer complete! Finished this camp: " + campID)
	#todo: may want to do partial progress on camp
	var camp = global.campData[campID]
	camp.inProgress = false
	camp.readyToCollect = true
	
func _on_questTimer_timeout(questID):
	#this is where the quest's random prizes are determined 
	global.logger(self, "Quest timer complete! Finished this quest: " + questID)
	var quest = global.questData[questID]
	quest.inProgress = false
	quest.readyToCollect = true
	quest.lootWon.questPrizeSC = round(rand_range(quest.scMin, quest.scMax))
	if (quest.hcMin != 0 && quest.hcMax != 0):
		quest.lootWon.questPrizeHC = round(rand_range(quest.hcMin, quest.hcMax))
	
	#this is just its NAME, not the item itself
	
	#Determine if player won item1 (generally more common) or item2 (generally more rare)
	#Roll 1-100
	#If number is <= than item1Chance, give item1
	#Roll 1-100 (again)
	#If number is <= than item2Chance, give item2
	
	var winItemRandom = 0
	if (quest.item1):
		winItemRandom = randi()%100+1 #1-100
		if (winItemRandom <= quest.item1Chance):
			quest.lootWon.questPrizeItem1 = quest.item1 
	if (quest.item2):
		winItemRandom = randi()%100+1 #1-100
		if (winItemRandom <= quest.item2Chance):
			quest.lootWon.questPrizeItem2 = quest.item2
			
	emit_signal("quest_complete", quest.name)

func _begin_tradeskill_timer(duration):
	var tradeskill = global.tradeskills[global.currentMenu]
	var recipe = tradeskill.selectedRecipe
	
	if (!tradeskill.inProgress):
		#set the currentlyCrafting item (this won't change as user browses recipes list and serves to "remember" the item being worked on)
		if (tradeskill.selectedRecipe.result != "computed"):
			tradeskill.currentlyCrafting.name = tradeskill.selectedRecipe.result
		elif (tradeskill.selectedRecipe.result == "computed"):
			tradeskill.currentlyCrafting.name = tradeskill.wildcardItem.name
			tradeskill.currentlyCrafting.statImproved = recipe.statImproved
			tradeskill.currentlyCrafting.statIncrease = recipe.statIncrease
		else:
			print("global.gd - Unknown result type")
		
		tradeskill.currentlyCrafting.totalTimeToFinish = duration #make record of how long this recipe needs to finish 
		tradeskill.inProgress = true
		tradeskill.readyToCollect = false
		tradeskill.timer = Timer.new()
		tradeskill.timer.set_one_shot(true)
		tradeskill.timer.set_wait_time(duration)
		tradeskill.timer.connect("timeout", self, "_on_tradeskillTimer_timeout", [global.currentMenu])
		tradeskill.timer.start()
		#todo: timer is added to scene, gets destroyed when you leave even though tradeskills is a global object 
		add_child(tradeskill.timer) 
	else:
		print("global.gd - error: " + tradeskill.name + " timer already running")

func _on_tradeskillTimer_timeout(tradeskillStr):
	var tradeskill = global.tradeskills[tradeskillStr]
	tradeskill.readyToCollect = true
	
func logger(script, message):
	print(script.get_name() + ": " + str(message))