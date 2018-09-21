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
onready var bedroomScene = preload("res://rooms/bedroom.tscn")
onready var blacksmithScene = preload("res://rooms/blacksmith.tscn")
onready var topEdgeScene = preload("res://rooms/topedge.tscn")
onready var placeholderRoomScene = preload("res://rooms/blacksmith.tscn")
onready var roomOrder = [bedroomScene, bedroomScene, blacksmithScene, topEdgeScene]
onready var roomCount = roomOrder.size() - 1
var newRoomCost = [0, 0, 0, 100, 200, 300, 400, 500, 600, 700, 800, 800, 900, 1000, 1000, 1000, 1000, 1000, 1000, 1000]

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

func _ready():
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
			
		print(classRestrictionsArray)
		global.allGameItems[itemKey].classRestrictions = classRestrictionsArray
		#print(global.items)
	#print("DPS test:" + str(global.allGameItems["Rusty Broadsword"]["dps"]))
	
	#for now, start the user off with some items (visible in the vault)
	global.guildItems.append(global.allGameItems["Rusty Broadsword"])
	global.guildItems.append(global.allGameItems["Novice's Blade"])
	global.guildItems.append(global.allGameItems["Sparkling Metallic Robe"])
	
	#here's a ton more
	global.guildItems.append(global.allGameItems["Basic Bow"])
	global.guildItems.append(global.allGameItems["Simple Ring"])
	global.guildItems.append(global.allGameItems["Silver Ring"])
	#global.guildItems.append(global.allGameItems["Rusty Knife"])
	#global.guildItems.append(global.allGameItems["Rusty Old Shield"])
	global.guildItems.append(global.allGameItems["Simple Chainmail Boots"])
	#global.guildItems.append(global.allGameItems["Chainmail Coif"])
	global.guildItems.append(global.allGameItems["Novice's Robe"])
	global.guildItems.append(global.allGameItems["Simple Grey Robe"])
	global.guildItems.append(global.allGameItems["Robe of Eternity"])
	global.guildItems.append(global.allGameItems["Robe of Alexandra"])
	global.guildItems.append(global.allGameItems["Cracked Wooden Buckler"])
	global.guildItems.append(global.allGameItems["Crimson Staff"])
	global.guildItems.append(global.allGameItems["Cloth Shirt"])
	global.guildItems.append(global.allGameItems["Cloth Pants"])
	global.guildItems.append(global.allGameItems["Cloth Headband"])
	global.guildItems.append(global.allGameItems["Tiara of Knowledge"])
	global.guildItems.append(global.allGameItems["Soft Silk Slippers"])
	global.guildItems.append(global.allGameItems["Softscale Boots"])
	global.guildItems.append(global.allGameItems["Seer's Orb"])
	
	#since we can't init the guildItems array to the size of the vault...
	global.guildItems.resize(vaultSpace)

	
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

func logger(script, message):
	print(script.get_name() + ": " + str(message))