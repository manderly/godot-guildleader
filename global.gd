#global.gd 
extends Node

var softCurrency = 500
var hardCurrency = 10
var currentMenu = "main"
var currentQuest = null
var selectedHero = null #which hero to show on heroPage
var guildRoster = []
var questHeroes = [null, null, null, null, null, null]
var questHeroesPicked = 0 #workaround for having to declare the array at-size 
var questButtonID = null
var questActive = false
var initDone = false
var levelXpData = null
var heroInventorySlots = ["Main", "Offhand", "Jewelry", "???", "Head", "Chest", "Legs", "Feet"]

func _ready():
	#Load hero level data 
	var file = File.new()
	file.open("res://gameData/levelXpData.json", file.READ)
	levelXpData = parse_json(file.get_as_text())
	file.close()
	
func _begin_global_quest_timer(duration):
	if (!questActive):
		print("starting quest timer: " + str(duration))
		questActive = true
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
	#give xp to each hero in quest list 
	#set status back to available
	#clear them out of the quest array 
	for i in range(questHeroes.size()):
		if (questHeroes[i] != null):
			questHeroes[i].heroXp += currentQuest.xp
			#if there's xp overflow, set xp to level total 
			if (questHeroes[i].heroXp > global.levelXpData[questHeroes[i].heroLevel].total):
				questHeroes[i].heroXp = global.levelXpData[questHeroes[i].heroLevel].total
			questHeroes[i].available = true
			questHeroes[i] = null
			questHeroesPicked -= 1
		

