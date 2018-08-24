#global.gd 
extends Node

var softCurrency = 500
var hardCurrency = 10
var currentMenu = "main"

var nextHeroID = 100

var selectedHero = null #which hero to show on heroPage
var guildRoster = []

var unrecruited = []

#active quest
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
	
func _begin_global_quest_timer(duration):
	if (!questActive):
		print("starting quest timer: " + str(duration))
		#emit_signal("quest_begun", currentQuest.name)
		questActive = true
		questReadyToCollect = false
		var questTimer = Timer.new()
		questTimer.set_one_shot(true)
		questTimer.set_wait_time(duration)
		questTimer.connect("timeout", self, "_on_questTimer_timeout")
		questTimer.start()
		add_child(questTimer)
	else:
		print("error: quest already running")
	
func _on_questTimer_timeout():
	print("Quest timer complete! Finished this quest: " + currentQuest.name)
	questActive = false
	questReadyToCollect = true
	questPrizeSC = round(rand_range(currentQuest.scMin, currentQuest.scMax))
	questPrizeHC = round(rand_range(currentQuest.hcMin, currentQuest.hcMax))
	questPrizeItem1 = "none" #todo: item system
	questPrizeItem2 = "none"
	emit_signal("quest_complete", currentQuest.name)

