#playervars.gd 
extends Node

var globalSoftCurrency = 123;
var currentQuest = null
var guildRoster = []
var questHeroes = [null, null, null, null, null, null]
var questButtonID = null
var questTimer = Timer.new()
var initDone = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	print(globalSoftCurrency) # can't figure out how to pass this to main 
	
	questTimer.set_one_shot(false)
	questTimer.connect("timeout", self, "_timer_callback")

func _timer_callback():
	print("Quest done")

