#global.gd 
extends Node
var nameGenerator = load("res://nameGenerator.gd").new()
var util = load("res://util.gd").new()

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
var questTimer = null
var currentQuest = null
var questHeroes = [null, null, null, null, null, null]
var questHeroesPicked = 0 #workaround for having to declare the array at-size 
var questButtonID = null
var questActive = false
var questReadyToCollect = false
#set these with random results when the quest is completed, then clear them out for next use
var questPrizeSC = 0
var questPrizeHC = 0
var questPrizeItem1 = null
var questPrizeItem2 = null
var winItemRandom = 0

var initDone = false
var levelXpData = null #from json 
var heroStartingStatData = null #from json

var roomTypeData = null
var itemData = null

#rooms
onready var rooms = []
onready var roomCount = 0
var newRoomCost = [100, 200, 300, 500, 700, 800, 900, 1000, 1000, 1000, 1000, 1000, 1000, 1000]

#tradeskill rooms
var blacksmithHero = null
var selectedBlacksmithingRecipe = null
var tailoringHero = null
var jewelcraftHero = null

#tradeskill stuff - timers, progress flags, etc
#blacksmithing
var blacksmithingTimer = null
var blacksmithingInProgress = false
var blacksmithingReadyToCollect = false
var blacksmithWildcardItem = null #for blades getting sharpened, armor getting augmented, etc. Holds 1. 

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
var swapItemSourceIdx = null
var inSwapItemState = false
var lastItemButtonClicked = null
var filterVaultByItemSlot = null
var browsingForSlot = ""
var browsingForType = ""

var blacksmithingRecipesData = null #raw json parse 
var allBlacksmithingRecipes = {} #dictionary with key value pairs representing each recipe 
var blacksmithingRecipes = [] #access them out of this array elsewhere

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
		global.questData[questKey] = questValue
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
		global.allGameItems[itemKey] = itemValue
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
		#print(global.items)
	#print("DPS test:" + str(global.allGameItems["Rusty Broadsword"]["dps"]))
	
	#since we can't init the guildItems array to the size of the vault...
	global.guildItems.resize(vaultSpace)
	
	#for now, start the user off with some items (visible in the vault)
	util.give_item_guild("Rusty Broadsword")
	util.give_item_guild("Novice's Blade")

	#here's a ton more for testing purposes 
	util.give_item_guild("Basic Bow")
	util.give_item_guild("Simple Ring")
	util.give_item_guild("Silver Ring")
	util.give_item_guild("Novice's Robe")
	#util.give_item_guild("Robe of Alexandra")
	#util.give_item_guild("Cloth Shirt")
	#util.give_item_guild("Cloth Pants")
	#util.give_item_guild("Tiara of Knowledge")

	#util.give_item_guild("Soft Silk Slippers")
	#util.give_item_guild("Softscale Boots")
	#util.give_item_guild("Seer's Orb")
	
	util.give_item_guild("Rough Stone")

	
	#load tradeskill crafting recipes
	var blacksmithingRecipesFile = File.new()
	blacksmithingRecipesFile.open("res://gameData/recipesBlacksmithing.json", blacksmithingRecipesFile.READ)
	blacksmithingRecipesData = parse_json(blacksmithingRecipesFile.get_as_text())
	blacksmithingRecipesFile.close()
	
	var recipeKey = null #a string, ie: "Sharpening Stone"
	var recipeValue = null #another dictionary, ie: {name:"name", ingredient1:"some thing"}
	
	#want to be able to access like: 
	#var recipe = find("Sharpening Stone")
	#then access stats like: item.dps, item.str etc by name 
	#["Sharpening Stone"]["ingredient1"]
	
	#first, make every recipe into an object with the recipe name as the key and all the data as the value
	for i in range(blacksmithingRecipesData.size()):
		recipeKey = blacksmithingRecipesData[i]["recipeName"]
		recipeValue = blacksmithingRecipesData[i]
		allBlacksmithingRecipes[recipeKey] = recipeValue
	#second, append each recipe into the array that we'll access them from elsewhere in the game
		blacksmithingRecipes.append(allBlacksmithingRecipes[recipeKey])
	
	if (!global.selectedBlacksmithingRecipe):
		global.selectedBlacksmithingRecipe = blacksmithingRecipes[0]
	
func _begin_global_quest_timer(duration):
	if (!questActive):
		print("starting quest timer: " + str(duration))
		#emit_signal("quest_begun", currentQuest.name)
		questActive = true
		questReadyToCollect = false
		questTimer = Timer.new()
		questTimer.set_one_shot(true)
		questTimer.set_wait_time(duration)
		questTimer.connect("timeout", self, "_on_questTimer_timeout")
		questTimer.start()
		add_child(questTimer)
	else:
		print("error: quest already running")
	
func _on_questTimer_timeout():
	#this is where the quest's random prizes are determined 
	global.logger(self, "Quest timer complete! Finished this quest: " + currentQuest.name)
	questActive = false
	questReadyToCollect = true
	questPrizeSC = round(rand_range(currentQuest.scMin, currentQuest.scMax))
	if (currentQuest.hcMin != 0 && currentQuest.hcMax != 0):
		questPrizeHC = round(rand_range(currentQuest.hcMin, currentQuest.hcMax))
	
	#this is just its NAME, not the item itself
	
	#Determine if player won item1 (generally more common) or item2 (generally more rare)
	#Roll 1-100
	#If number is <= than item1Chance, give item1
	#Roll 1-100 (again)
	#If number is <= than item2Chance, give item2
	
	if (currentQuest.item1):
		winItemRandom = randi()%100+1 #1-100
		if (winItemRandom <= currentQuest.item1Chance):
			questPrizeItem1 = currentQuest.item1 
	if (currentQuest.item2):
		winItemRandom = randi()%100+1 #1-100
		if (winItemRandom <= currentQuest.item2Chance):
			questPrizeItem2 = currentQuest.item2
			
	emit_signal("quest_complete", currentQuest.name)

#blacksmithing timer
func _begin_global_blacksmithing_timer(duration):
	if (!blacksmithingInProgress):
		print("global.gd - starting blacksmithing timer: " + str(duration))
		#emit_signal("quest_begun", currentQuest.name)
		blacksmithingInProgress = true
		blacksmithingReadyToCollect = false
		blacksmithingTimer = Timer.new()
		blacksmithingTimer.set_one_shot(true)
		blacksmithingTimer.set_wait_time(duration)
		blacksmithingTimer.connect("timeout", self, "_on_blacksmithingTimer_timeout")
		blacksmithingTimer.start()
		add_child(blacksmithingTimer)
	else:
		print("global.gd - error: Blacksmithing timer already running")

func _on_blacksmithingTimer_timeout():
	#this is where the quest's random prizes are determined 
	global.logger(self, "blacksmithingTimer complete!")
	#blacksmithingInProgress = false
	blacksmithingReadyToCollect = true
	
func logger(script, message):
	print(script.get_name() + ": " + str(message))