extends Node
#global.gd 
#used for gameplay vars unique to each player game 
#what belongs in this file:
	#vars that would be unique across different players' games
	#vars that get saved as the game is played
	
#todo: localization support
# [{'EN': {'craftingButtonText': 'Crafting'}}, {'JP': {'craftingButtonText': 'Tsukurimono'}} 

var nameGenerator = load("res://nameGenerator.gd").new()
#var mobGenerator = load("res://mobGenerator.gd").new()
#var encounterGenerator = load("res://encounterGenerator.gd").new()

var testTimerBeginTime = 0
var testTimerEndTime = 0

var softCurrency = 500
var hardCurrency = 500
var currentMenu = "main"
var currentRoomID = ""
var vaultSpace = 25 #should be a multiple of 5
var maxHeroLevel = 30
var surnameLevel = 20
var guildName = "" 
var namesInUse = []
var tickRate = 10
var lastIdlePositionShuffle = 0 # replace with unix timestamp, compare in main.gd 

var cameraPosition = Vector2(-14,2)
var mainScreenTop = 0

var onscreenHeroes = []

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage
var selectedBedroom = null # for telling the bedroom scenes apart in menus 
var whichBed = null # for putting quilts on the CORRECT bed in each bedroom

var guildRoster = []
var guildCapacity = 6 #each bedroom adds +2 capacity 

const bedroomMaxOccupancy = 2 

# bedroom assignments are separate from a hero being physically IN their bedroom
var bedrooms = {} # add to every time a bedroom is added, look in roomGenerator.gd
var bedroomCount = 0

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
var tradeskillRoomsToBuild = ["blacksmith", "alchemy", "woodcraft", "jewelcraft", "tailoring", "chronomancy", "cooking"] #remove from array as they are built 

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
var guildItems = null
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
var vault = null # instance of inventory, instantiated in ready()

func _ready():
	randomize()
	
	#Name the guild!
	global.guildName = nameGenerator.generateGuildName()
	
	# Init the inventories
	# Note: quest items and tradeskill items are just fungible stacks of items, they 
	# do not have (or need) all the moving/sorting abilities that vault items need
	global.vault = load("res://inventory.gd").new()
	global.playerQuestItems = {}
	global.playerTradeskillItems = {}

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
		
	if (!global.tradeskills["woodcraft"].selectedRecipe):
		global.tradeskills["woodcraft"].selectedRecipe = global.tradeskills.woodcraft.recipes[0]
				
	if (!global.tradeskills["jewelcraft"].selectedRecipe):
		global.tradeskills["jewelcraft"].selectedRecipe = global.tradeskills.jewelcraft.recipes[0]
	
	if (!global.tradeskills["tailoring"].selectedRecipe):
		global.tradeskills["tailoring"].selectedRecipe = global.tradeskills.tailoring.recipes[0]
	
	if (!global.tradeskills["cooking"].selectedRecipe):
		global.tradeskills["cooking"].selectedRecipe = global.tradeskills.tailoring.recipes[0]	
	
	#since we can't init the guildItems array to the size of the vault...
	global.vault.resize(vaultSpace)
	
	#for now, start the guild off with some vault items
	# the vault is an instance of inventory.gd 
	util.give_new_item_guild("Rusty Broadsword", 1)
	util.give_new_item_guild("Novice's Blade", 2)
	#here's some uber loot for testing purposes 
	util.give_new_item_guild("Deadeye", 1)
	util.give_new_item_guild("Simple Ring", 1)
	util.give_new_item_guild("Crimson Staff", 1)
	util.give_new_item_guild("Staff of the Four Winds", 1)
	util.give_new_item_guild("Obsidian Quickblade", 1)
	util.give_new_item_guild("Robe of Alexandra", 1)
	util.give_new_item_guild("Sparkling Metallic Robe", 1)
	util.give_new_item_guild("Robe of the Dunes", 1)
	util.give_new_item_guild("Prestige Robe", 1)
	util.give_new_item_guild("Softscale Boots", 1)
	util.give_new_item_guild("Seer's Orb", 1)
	util.give_new_item_guild("Bladestorm", 2)
	
	util.give_new_item_guild("Scepter of the Child King", 1)
	util.give_new_item_guild("Rough Stone", 15)
	util.give_new_item_guild("Leather Strip", 5)
	util.give_new_item_guild("Small Brick of Ore", 1)
	util.give_new_item_guild("Copper Ore", 10)
	util.give_new_item_guild("Silver Ore", 10)
	util.give_new_item_guild("Gold Ore", 10)
	util.give_new_item_guild("Topaz", 2)
	util.give_new_item_guild("Pearl", 2)
	
	util.give_new_item_guild("Azuricite Metal", 10)
	util.give_new_item_guild("Leather Padding", 6)

	util.give_new_item_guild("Caster's Circlet", 1)
	
	util.give_new_item_guild("Comfy Quilt", 2)
	
	util.give_new_item_guild("Small Egg", 10)
	util.give_new_item_guild("Bread Flour", 10)
	util.give_new_item_guild("Water Flask", 10)
	util.give_new_item_guild("Bread Yeast", 10)
	
	util.give_new_item_guild("Mixed Seeds", 10)
	util.give_new_item_guild("Tasty Seasoning", 10)
	util.give_new_item_guild("Simple Greens", 10)
	util.give_new_item_guild("Forest Berries", 10)
	util.give_new_item_guild("Small Seeds", 10)
	util.give_new_item_guild("Plain Oats", 10)
	util.give_new_item_guild("Cooking Oil", 10)
	util.give_new_item_guild("Small Sugar", 10)

	
func logger(script, message):
	print(script.get_name() + ": " + str(message))
	
func save():
	var save_object = {
			"filename":"res://global.gd", #res://hero.tscn
			"parent":get_parent().get_path(),
			"guildName":guildName,
			"tradeskills":tradeskills,
			"bedrooms":bedrooms,
			"training":training,
			"softCurrency":softCurrency,
			"hardCurrency":hardCurrency,
			"initDone":initDone,
			"nextHeroID":nextHeroID,
			"rooms":rooms,
			"roomCount":roomCount,
			"testTimerBeginTime":testTimerBeginTime,
			"testTimerEndTime":testTimerEndTime,
			"activeHarvestingData":activeHarvestingData,
			"activeCampData":activeCampData,
			"vault":vault
		}
	return save_object 