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
var levelXpData = null #from json 
var heroStartingStatData = null #from json

var guildRoster = []
var guildCapacity = 4 #each bedroom adds +2 capacity 

var unrecruited = []

#Filereading
var unformattedData = null

#Global tables (mob, loot, quest, etc)
var mobData = {}
var lootTables = {}
var questData = {}
var harvestingData = {}
var allRecipes = {}
var campData = {}
var allGameQuests = {}

var selectedHarvestingID = null

var activeQuests = []
var selectedQuestID = ""

var questButtonID = null

#camp data
var campButtonID = null
var selectedCampID = null #used by quest confirm to pass data to correct quest sub-object in questData object
var currentCamp = null

var roomTypeData = null
var itemData = null
var nextItemID = 100

var initDone = false
var returnToMap = ""

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
		"wildcardItemOnDeck": null,
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
		"wildcardItemOnDeck": null,
		"displayName": "Blacksmithing",
		"description": "Combine fire and metal to craft weapons and armor from ore, metals, and other materials.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"moddingAnItem":false,
			"wildcardItem":null,
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
		"wildcardItemOnDeck": null,
		"displayName": "Fletching",
		"description":"Make arrows and bows",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"moddingAnItem":false,
			"wildcardItem":null,
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
		"wildcardItemOnDeck": null,
		"displayName": "Jewelcraft",
		"description":"Bend metal and gemstones into sparkly jewelry with powerful stat bonuses.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"moddingAnItem":false,
			"wildcardItem":null,
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
		"wildcardItemOnDeck": null,
		"displayName": "Tailoring",
		"description":"Turn cloth and leather into useful items, such as robes, vests, and padding for plate armor made by blacksmiths.",
		"recipes": [],
		"selectedRecipe": null,
		"currentlyCrafting": {
			"moddingAnItem":false,
			"wildcardItem":null,
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

var colorGreen = Color(.062, .90, .054, 1) #16,230,14 green
var colorBlue = Color(.070, .313, .945, 1) #18,80,241 blue
var colorPink = Color(.945, .070, .525, 1) #241,18,134 pink
var colorWhite = Color(1, 1, 1, 1) #white
var colorYellow = Color(.93, .913, .25, 1) #yellow

func _ready():
	randomize()
	
	#Name the guild!
	global.guildName = nameGenerator.generateGuildName()
	
	#Prepare to load game data. These use global.unformattedData
	var key = null #a string, ie: "Tadloc Grunt"
	var value = null #another dictionary, ie: {dps:4, str:5}
	
	###### Load mob data ######
	#(mobs are a lot like items, they have names and stats and we access them by their name)
	#but we don't need instances of them like we do heroes, they don't really persist the way heroes do
	util.prepare_unformatted_data_from_file("mobs.json")
	for mob in global.unformattedData:
		if (mob):
			key = mob["mobName"]
			value = mob
			#add anything else to mobValue here, ie: mobValue["someNewStatNotInData"] = 5
			value.hpCurrent = int(value.hp)
			value.manaCurrent = int(value.mana)
			value.dead = false
			global.mobData[key] = value
	
	###### Load loot table data ######
	util.prepare_unformatted_data_from_file("lootTables.json")
	for lootTable in global.unformattedData:
		if (lootTable):
			key = lootTable["lootTableName"] #key: a string, ie: ratLoot01
			value = lootTable  #value: another dictionary, ie: {item1: itemname, item1Chance: 20}
			#add anything else to value here, 
			global.lootTables[key] = value
	
	###### Load quest data ######
	util.prepare_unformatted_data_from_file("quests.json")
	#Access quests by id, ie: "forest01"
	for quest in global.unformattedData:
		key = quest["questId"] #a string, ie: "forest01"
		value = quest #another dictionary, ie: {prize1:"prize name", heroes:3}
		value.timesRun = 0
		#loot won is filled in when the quest is completed and held in the object until collected, then it is nulled out for re-use
		global.allGameQuests[key] = value
	#now we have all the quest data as a dictionary
	#give quests to the player like if they were items
	util.give_quest("test09")
	util.give_quest("test10")
	util.give_quest("azuricite_quest01")
	global.selectedQuestID = "test09"
	
	###### Load harvesting node data ######
	#Access harvest node by id
	util.prepare_unformatted_data_from_file("harvesting.json")
	for data in global.unformattedData:
		key = data["harvestingId"] #a string, ie: "harvesting_copperOre"
		value = data #another dictionary, ie: {prize1:"prize name", heroes:3}
		value.hero = null
		value.timer = null
		value.inProgress = false
		value.readyToCollect = false
		value.timesRun = 0
		value.lootWon = {
			"prizeItem1":null,
			"prizeQuantity":0
		}
		global.harvestingData[key] = value
	
	###### Load camp data ######
	util.prepare_unformatted_data_from_file("camps.json")
	for data in global.unformattedData:
		key = data["campId"]
		value = data
		#breaks manual selection if done in camp.gd 
		value.heroes = []
		for hero in value.groupSize:
			value.heroes.append(null)
		value.mobs = []
		if (value.mob1):
			value.mobs.append(mobGenerator.get_mob(value.mob1))
		if (value.mob2):
			value.mobs.append(mobGenerator.get_mob(value.mob2))
		if (value.mob3):
			value.mobs.append(mobGenerator.get_mob(value.mob3))
		value.timer = null
		value.inProgress = false
		value.readyToCollect = false
		value.timesRun = 0
		value.campHeroesSelected = 0
		value.selectedDuration = 0
		value.enableButton = ""
		value.campOutcome = {}
		#to set a camp: global.currentCamp = global.campData["camp_forest01"]
		global.campData[key] = value
	
	###### Load room type data ######
	util.prepare_unformatted_data_from_file("roomTypes.json")
	roomTypeData = global.unformattedData
	
	###### Load hero level data ######
	util.prepare_unformatted_data_from_file("levelXpData.json")
	levelXpData = global.unformattedData
	
	###### Load hero stat data ######
	#access an individual class's stats like this: 
	#print(str(heroStartingStatData[0]["rogue"]["defense"]))
	util.prepare_unformatted_data_from_file("heroStats.json")
	heroStartingStatData = global.unformattedData[0]
	
	###### Load hero names ######
	util.prepare_unformatted_data_from_file("names/humanMale.json")
	humanMaleNames = global.unformattedData
	util.prepare_unformatted_data_from_file("names/humanFemale.json")
	humanFemaleNames = global.unformattedData
	
	###### Load items ######
	util.prepare_unformatted_data_from_file("items.json")
	#Access like: var item = global.allGameItems("Rusty Broadsword")
	
	for item in global.unformattedData:
		key = item["name"] #a string, ie: "Rusty Broadsword"
		value = item #another dictionary, ie: {dps:4, str:5}
		value["itemID"] = -1 #ID isn't assigned until we actually give this item to the guild or a hero
		value["improved"] = false
		value["improvement"] = ""
		global.allGameItems[key] = value
		
		#if it's a tradeskill item, put it in the tradeskill items dictionary
		if (value["itemType"] == "tradeskill"):
			tradeskillItemsDictionary[key] = {
				"count": 0,
				"name":key,
				"icon":value.icon,
				"seen":false,
				"consumable":value.consumable
				}
		elif (value["itemType"] == "quest"): #or put it in the quest items dictionary
			questItemsDictionary[key] = {
				"count":0,
				"name":key,
				"icon":value.icon,
				"seen":false,
				"consumable":value.consumable
				}
		else:	
			var classRestrictionsArray = []
			classRestrictionsArray.append(global.allGameItems[key].classRestriction1)
			if (global.allGameItems[key].classRestriction2 != ""):
				classRestrictionsArray.append(global.allGameItems[key].classRestriction2)
			if (global.allGameItems[key].classRestriction3 != ""):
				classRestrictionsArray.append(global.allGameItems[key].classRestriction3)
			if (global.allGameItems[key].classRestriction4 != ""):
				classRestrictionsArray.append(global.allGameItems[key].classRestriction4)
			if (global.allGameItems[key].classRestriction5 != ""):
				classRestrictionsArray.append(global.allGameItems[key].classRestriction5)
			
			global.allGameItems[key].classRestrictions = classRestrictionsArray
	
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
	
	###### Load tradeskill crafting recipes ######
	util.prepare_unformatted_data_from_file("recipes.json")
	
	#first, make every recipe into an object with the recipe name as the key and all the data as the value
	for recipe in global.unformattedData:
		key = recipe["recipeName"]  #a string, ie: "Sharpening Stone"
		value = recipe #another dictionary, ie: {name:"name", ingredient1:"some thing"}
		#add this data to the key in allRecipes
		allRecipes[key] = value
		#second, append each recipe into the array that we'll access them from elsewhere in the game
		#this syntax is like: tradeskills["blacksmithing"].recipes.append(...)
		tradeskills[recipe.tradeskill].recipes.append(allRecipes[key])
		
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
			tradeskill.currentlyCrafting.name = tradeskill.currentlyCrafting.wildcardItem.name
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