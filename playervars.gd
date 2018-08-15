#playervars.gd 

extends Node

var globalSoftCurrency = 123;
var currentQuest = null
var guildRoster = []
var questHeroes = [null, null, null, null, null, null]
var questButtonID = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	print(globalSoftCurrency) # can't figure out how to pass this to main 

