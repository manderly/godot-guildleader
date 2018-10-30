extends Node
# encounterGenerator.gd 

# Terminology: 
# an encounter is the entire thing
# a battle is part of an encounter

# takes: 
# - the number of battles to generate
# - the heroes involved and their stats
# - the enemies involved and their stats
# -- a camp has three mob types associated with it, and those can come as singletons or groups for each battle

# calculates:
# - winner/loser of each encounter based on formulas found within 

# returns:
# - object detailing the outcomes of each encounter, including loot and which heroes are now dead 
# - this object has to be useful for displaying battle data to the player

#Battle object is used as such: 
#Fight #1: Heroes vs. Mob name
	#Heroes won
	#123 soft currency
	#1 hard currency
	#This rare item: Item Name
	
#Fight #2: Heroes vs. Mob name (rare spawn!)
	#Mobs won
	#0 soft currency
	#0 hard currency
	#No items
	#Soandso almost died, but was healed in time by Healername
	#(or: Soandso died) 

#populate battleRecord array with battle objects
#populate loot with names of items won
#populate sc and hc with totals of currency won 
var encounterOutcome = {
	"battleRecord":[],
	"lootTotal":[],
	"scTotal":0,
	"hcTotal":0
}

#todo: track how much xp each hero gets individually for display later 

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _get_rand_between(bottom, top):
	var randNum = randi()%top+bottom #1-100, 5-10, 600-1900, etc 
	return randNum
	
func _calculate_battle_outcome(heroes, mobs):
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":heroes,
		"mobs":mobs,
		"winner":"",
		"loot":null,
		"sc":0,
		"hc":0,
		"xp:":0
	}

	var outcomeNum = _get_rand_between(1, 2)
	var winnerStr = ""
	if (outcomeNum == 1):
		winnerStr = "heroes"
		newBattle.loot = "Rusty Broadsword" #todo: randomly win loot
		newBattle.xp = 15 #todo: formulaize this
		for hero in newBattle.heroes:
			hero.give_xp(15)
		newBattle.sc = _get_rand_between(1, 100)
		newBattle.hc = _get_rand_between(0, 2)
	else:
		winnerStr = "mobs"
		newBattle.xp = 1
		#todo: determine if a hero dies
		newBattle.sc = 0
		newBattle.hc = 0
		
	newBattle.winner = winnerStr
	return newBattle
	
func calculate_encounter_outcome(camp): #pass in the entire camp object
	#use duration to determine how many encounters (battles) happen
	#duration comes in as seconds, so divide by 60 to make it 1 encounter per minute
	var encounterQuantity = camp.selectedDuration / 60
	for encounter in encounterQuantity:
		#generate N battles and save their outcomes 
		var battleOutcome = _calculate_battle_outcome(camp.heroes, camp.mobs)
		encounterOutcome.battleRecord.append(battleOutcome)
		encounterOutcome.lootTotal.append(battleOutcome["loot"])
		encounterOutcome.scTotal += battleOutcome["sc"]
		encounterOutcome.hcTotal += battleOutcome["hc"]
	return encounterOutcome