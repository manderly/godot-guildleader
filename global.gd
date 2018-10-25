#global.gd 
extends Node
var nameGenerator = load("res://nameGenerator.gd").new()

var softCurrency = 500
var hardCurrency = 10
var currentMenu = "main"
var vaultSpace = 25 #should be a multiple of 5
var guildName = "" 

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage
var guildRoster = []
var guildCapacity = 4 #each bedroom adds +2 capacity 

var unrecruited = []

var unformattedQuestData = null
var questData = {}

#active quest
var questButtonID = null
var selectedQuestID = null #used by quest confirm to pass data to correct quest sub-object in questData object
var initDone = false
var levelXpData = null #from json 
var heroStartingStatData = null #from json

var roomTypeData = null
var itemData = null
var nextItemID = 100

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
	
	#Load quest data
	var questFile = File.new()
	questFile.open("res://gameData/quests.json", questFile.READ)
	var unformattedQuestData = parse_json(questFile.get_as_text())
	questFile.close()
	
	#so we can access quests by ID 
	var questKey = null #a string, ie: "forest01"
	var questValue = null #another dictionary, ie: {prize1:"prize name", heroes:3}
	for i in range(unformattedQuestData.size()):
		questKey = unformattedQuestData[i]["questId"]
		questValue = unformattedQuestData[i]
		questValue.heroes = [null, null, null]
		questValue.timer = null
		questValue.inProgress = false
		questValue.readyToCollect = false
		questValue.timesRun = 0
		questValue.lootWon = {
			"questPrizeSC":0,
			"questPrizeHC":0,
			"questPrizeItem1":null,
			"questPrizeItem2":null
		}
		#loot won is filled in when the quest is completed and held in the object until collected, then it is nulled out for re-use
		global.questData[questKey] = questValue
		
	#todo: refactor into a concurrent quest system so many quests can run simultaneously provided the player has enough heroes 
	#to set a quest: global.currentQuest = global.questData["forest01"]
	
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
	#here's a ton more for testing purposes 
	util.give_item_guild("Basic Bow")
	util.give_item_guild("Simple Ring")
	util.give_item_guild("Crimson Staff")
	util.give_item_guild("Staff of the Four Winds")
	util.give_item_guild("Obsidian Quickblade")
	util.give_item_guild("Robe of Alexandra")
	util.give_item_guild("Simple Grey Robe")
	util.give_item_guild("Blue Cotton Robe")
	util.give_item_guild("Sparkling Metallic Robe")
	util.give_item_guild("Robe of the Dunes")
	util.give_item_guild("Prestige Robe")
	util.give_item_guild("Softscale Boots")
	util.give_item_guild("Seer's Orb")
	
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
		add_child(tradeskill.timer) #trying to make this global 
	else:
		print("global.gd - error: " + tradeskill.name + " timer already running")


func _on_tradeskillTimer_timeout(tradeskillStr):
	var tradeskill = global.tradeskills[tradeskillStr]
	tradeskill.readyToCollect = true
	
func logger(script, message):
	print(script.get_name() + ": " + str(message))