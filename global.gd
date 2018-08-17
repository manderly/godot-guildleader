#global.gd 
extends Node

var globalSoftCurrency = 123;
var currentQuest = null
var guildRoster = []
var questHeroes = [null, null, null, null, null, null]
var questHeroesPicked = 0 #workaround for having to declare the array at-size 
var questButtonID = null
var questActive = false
var initDone = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	print(globalSoftCurrency) # can't figure out how to pass this to main 
	
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
			questHeroes[i].available = true
			questHeroes[i] = null
			questHeroesPicked -= 1
		

