extends Node
#global.gd 
#used for gameplay vars unique to each player game 
#what belongs in this file:
	#vars that would be unique across different players' games
	#vars that get saved as the game is played
	
#todo: localization support
# [{'EN': {'craftingButtonText': 'Crafting'}}, {'JP': {'craftingButtonText': 'Tsukurimono'}} 

var nameGenerator = load("res://nameGenerator.gd").new()
var mobGenerator = load("res://mobGenerator.gd").new()
var encounterGenerator = load("res://encounterGenerator.gd").new()

var testTimerBeginTime = 0
var testTimerEndTime = 0

var softCurrency = 500
var hardCurrency = 500
var currentMenu = "main"
var currentRoomID = ""
var vaultSpace = 25 #should be a multiple of 5
var guildName = "" 

var cameraPosition = Vector2(-14,2)
var mainScreenTop = 0

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage

var guildRoster = []
var guildCapacity = 4 #each bedroom adds +2 capacity 

var unrecruited = []

var unformattedData = null

#Quests, Harvest nodes, and Camps are all "one of a kind" and they're
#either active or idle, with heroes assigned to them.
#Since they vary by player save, they are kept in global.
var activeHarvestingData = {}
var activeCampData = {}

var selectedHarvestingID = null

var activeQuests = []
var selectedQuestID = ""

var questButtonID = null

#camp data
var campButtonID = null
var selectedCampID = null #used by quest confirm to pass data to correct quest sub-object in questData object
var currentCamp = null

var itemData = null
var nextItemID = 100

var initDone = false
var returnToMap = ""

#rooms
onready var rooms = []
onready var roomCount = 0
var newRoomCost = [10, 20, 30, 50, 70, 80, 90, 100, 1000, 1000, 1000, 1000, 1000, 1000]
var tradeskillRoomsToBuild = ["blacksmith", "alchemy", "fletching", "jewelcraft", "tailoring", "chronomancy"] #remove from array as they are built 

#tradeskill flags
#use: global.tradeskills[global.currentMenu] 
#example: global.tradeskills["alchemy"].hero
var tradeskills = {} #build this object later 
var training = {}
var trainingRoomCount = 0

#the x min and max is the same for all rooms
var roomMinX = 200
var roomMaxX = 360

#signal quest_begun
signal quest_complete

#items inventory / vault
var guildItems = []
var tradeskillItemsSeen = [] #keep track of all the tradeskill items we've encountered, never remove
var playerTradeskillItems = {} #keep count of tradeskill items and their counts here
var questItemsSeen = [] #keep track of all the quest items we've encountered, todo: player can remove
var playerQuestItems = {} #keep count of quest items and their counts here
var swapItemSourceIdx = null
var inSwapItemState = false
var lastItemButtonClicked = null
var filterVaultByItemSlot = null
var browsingForSlot = ""
var browsingForType = ""


func _ready():
	randomize()
	
	#Name the guild!
	global.guildName = nameGenerator.generateGuildName()

	#get the static data that was already built for us by Parsely	
	global.tradeskills = timedNodeData.tradeskills
	global.activeHarvestingData = timedNodeData.harvesting
	global.activeCampData = timedNodeData.camps
	global.training = timedNodeData.training
	global.playerTradeskillItems = dynamicData.playerTradeskillItems
	global.playerQuestItems = dynamicData.playerQuestItems
	
	#Now that we have a tradeskill object for each tradeskill,
	#populate its recipe array with the pertinent recipe objects
	for recipe in staticData.recipes:
		global.tradeskills[recipe.tradeskill].recipes.append(recipe)
	
	#And set defaults if none exist yet
	if (!global.tradeskills["alchemy"].selectedRecipe):
		global.tradeskills["alchemy"].selectedRecipe = global.tradeskills.alchemy.recipes[0]
		
	if (!global.tradeskills["blacksmithing"].selectedRecipe):
		global.tradeskills["blacksmithing"].selectedRecipe = global.tradeskills.blacksmithing.recipes[0]
		
	if (!global.tradeskills["chronomancy"].selectedRecipe):
		global.tradeskills["chronomancy"].selectedRecipe = global.tradeskills.chronomancy.recipes[0]
		
	if (!global.tradeskills["fletching"].selectedRecipe):
		global.tradeskills["fletching"].selectedRecipe = global.tradeskills.fletching.recipes[0]
				
	if (!global.tradeskills["jewelcraft"].selectedRecipe):
		global.tradeskills["jewelcraft"].selectedRecipe = global.tradeskills.jewelcraft.recipes[0]
	
	if (!global.tradeskills["tailoring"].selectedRecipe):
		global.tradeskills["tailoring"].selectedRecipe = global.tradeskills.tailoring.recipes[0]
		
	
	#since we can't init the guildItems array to the size of the vault...
	guildItems.resize(vaultSpace)
	
	#for now, start the user off with some items (visible in the vault)
	util.give_item_guild("Rusty Broadsword")
	util.give_item_guild("Novice's Blade")
	util.give_item_guild("Novice's Blade")
	#here's some uber loot for testing purposes 
	util.give_item_guild("Deadeye")
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

	
func logger(script, message):
	print(script.get_name() + ": " + str(message))
	
func save():
	var save_object = {
			"filename":"res://global.gd", #res://hero.tscn
			"parent":get_parent().get_path(),
			"guildName":guildName,
			"tradeskills":tradeskills,
			"softCurrency":softCurrency,
			"hardCurrency":hardCurrency,
			"initDone":initDone,
			"nextHeroID":nextHeroID,
			"rooms":rooms,
			"roomCount":roomCount,
			"testTimerBeginTime":testTimerBeginTime,
			"testTimerEndTime":testTimerEndTime,
			"activeHarvestingData":activeHarvestingData,
			"activeCampData":activeCampData
		}
	return save_object 