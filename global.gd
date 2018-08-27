#global.gd 
extends Node

var softCurrency = 500
var hardCurrency = 10
var currentMenu = "main"
var vaultSpace = 18 #should be a multiple of 6

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage
var guildRoster = []

var unrecruited = []

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
var questPrizeItem1 = "none"
var questPrizeItem2 = "none"

var initDone = false
var levelXpData = null #from json 
var heroStartingStatData = null #from json
var heroInventorySlots = ["Main", "Offhand", "Jewelry", "???", "Head", "Chest", "Legs", "Feet"]

var roomTypeData = null
var itemData = null

#rooms
onready var bedroomScene = preload("res://rooms/bedroom.tscn")
onready var blacksmithScene = preload("res://rooms/blacksmith.tscn")
onready var topEdgeScene = preload("res://rooms/topedge.tscn")
onready var placeholderRoomScene = preload("res://rooms/blacksmith.tscn")
onready var roomOrder = [bedroomScene, bedroomScene, blacksmithScene, topEdgeScene]
onready var roomCount = roomOrder.size() - 1
var newRoomCost = [0, 0, 0, 100, 200, 300, 400, 500, 600, 700, 800, 800, 900, 1000, 1000, 1000, 1000, 1000, 1000, 1000]

#signal quest_begun
signal quest_complete

#items
var allGameItems = {}
var guildItems = []

func _ready():
	#Load room type data and save it to a global var
	var roomTypeFile = File.new()
	roomTypeFile.open("res://gameData/roomTypes.json", roomTypeFile.READ)
	roomTypeData = parse_json(roomTypeFile.get_as_text())
	print(roomTypeData)
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
		#print(global.items)
	#print("DPS test:" + str(global.allGameItems["Rusty Broadsword"]["dps"]))
	
	#for now, start the user off with some items (visible in the vault)
	global.guildItems.append(global.allGameItems["Rusty Broadsword"])
	global.guildItems.append(global.allGameItems["Blue Cotton Robe"])
	
	#here's a ton more
	global.guildItems.append(global.allGameItems["Basic Bow"])
	global.guildItems.append(global.allGameItems["Simple Ring"])
	global.guildItems.append(global.allGameItems["Rusty Knife"])
	global.guildItems.append(global.allGameItems["Rusty Old Shield"])
	global.guildItems.append(global.allGameItems["Chainmail Boots"])
	global.guildItems.append(global.allGameItems["Chainmail Coif"])
	global.guildItems.append(global.allGameItems["Shabby Robe"])
	global.guildItems.append(global.allGameItems["Simple Grey Robe"])
	global.guildItems.append(global.allGameItems["Cloth Shirt"])

	
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
	print("Quest timer complete! Finished this quest: " + currentQuest.name)
	questActive = false
	questReadyToCollect = true
	questPrizeSC = round(rand_range(currentQuest.scMin, currentQuest.scMax))
	questPrizeHC = round(rand_range(currentQuest.hcMin, currentQuest.hcMax))
	#this is just its NAME, not the item itself 
	questPrizeItem1 = currentQuest.item1 #todo: random chance to win this item, not guaranteed
	questPrizeItem2 = "none"
	#now in questComplete.gd, we access these vars as global vars such as:
	#global.questPrizeItem1 
	emit_signal("quest_complete", currentQuest.name)

