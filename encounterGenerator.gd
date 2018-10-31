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

func _get_rand_between(firstVal, secondVal):
	var bottom = firstVal
	var top = secondVal
	
	if (secondVal < firstVal): #figure out which value is lower (ie: if we pass (8,0) we can't use them as-is) 
		bottom = secondVal
		top = firstVal
	print("getting random between " + str(bottom) + " and " + str(top))	
	var randNum = randi()%int(top)+int(bottom) #1-100, 5-10, 600-1900, etc
	return randNum
	
func _calculate_entity_score(entities):
	#use to determine a "score" value for a group of heroes or a group of mobs
	#super rudimentary right now, it just sums hp
	var hpTotal = 0
	for entity in entities:
		hpTotal += entity.hp
	return hpTotal
	
func _get_battle_mobs(mobs):
	#in a battle, it's all the available heroes vs. a random assortment of mobs
	var mobAssortment = []
	#eventually, we'll pass in a min and max quantity of mobs
	#but for now, 1-3 mobs will do
	var battleMobsQuantity = _get_rand_between(1, 5)
	#now figure out which mobs those are, exactly
	#todo: use rarities as designed in the data sheet (right now they are all equally likely) 
	var randomMob = null
	for i in battleMobsQuantity:
		var randMobNum = _get_rand_between(1, 3) #never picks 2 if you pass it (0,2)
		randomMob = mobs[randMobNum - 1]
		mobAssortment.append(randomMob)
	return mobAssortment
	
func _calculate_battle_outcome(heroes, mobTable):
	var randomMobs = _get_battle_mobs(mobTable)
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":heroes,
		"mobs":randomMobs,
		"winner":"",
		"loot":null,
		"sc":0,
		"hc":0,
		"xp:":0
	}
	
	#determine which mobs are gonna fight in this battle
	var heroScore = _calculate_entity_score(heroes)
	var mobScore = _calculate_entity_score(randomMobs)
	print("heroScore: " + str(heroScore) + " mobScore: " + str(mobScore))
	#now figure out which is lower
	var outcomeNum = 0
	if (heroScore <= mobScore): #ie: heroes are 50 and mobs are 80
		#heroes have a chance based on the gulf between their score and mob score
		#heroes win if outcome is 0-50 in this case
		outcomeNum = _get_rand_between(0, mobScore)
		print("Heroes are weaker. outcomeNum: " + str(outcomeNum))
		if (outcomeNum <= heroScore):
			#heroes win
			newBattle.winner = "heroes"
			newBattle.loot = "Rusty Broadsword" #todo: randomly win loot
			newBattle.xp = 15 #todo: formulaize this
			for hero in newBattle.heroes:
				hero.give_xp(15)
			newBattle.sc = _get_rand_between(1, 100)
			newBattle.hc = _get_rand_between(0, 2)
		else:
			#mobs win
			newBattle.winner = "mobs"
			newBattle.xp = 1
			#todo: determine if a hero dies
			newBattle.sc = 0
			newBattle.hc = 0
	elif (heroScore > mobScore): #ie: heroes are 100 and mobs are 20
		#we want the mobs to still have a tiny chance, but heroes should win most of the time here
		#heroes win if outcome is 21-100 in this case, lose if outcome is 0-20
		#but since the heroes are higher level, we get a level modifier as well (this is rudimentary for now)
		#the level modifier is just +10 to the roll outcome to make it more likely heroes win in cases like
		#heroes 100, mobs 50. Heroes should definitely stomp the mobs in this case. 
		outcomeNum = _get_rand_between(0, heroScore)
		outcomeNum += 10
		print("Mobs are weaker. outcomeNum: " + str(outcomeNum))
		if (outcomeNum <= mobScore):
			#mobs win
			newBattle.winner = "mobs"
			newBattle.xp = 1
			#todo: determine if a hero dies
			newBattle.sc = 0
			newBattle.hc = 0
		else:
			newBattle.winner = "heroes"
			newBattle.loot = "Rusty Broadsword" #todo: randomly win loot
			newBattle.xp = 15 #todo: formulaize this
			for hero in newBattle.heroes:
				hero.give_xp(15)
			newBattle.sc = _get_rand_between(1, 100)
			newBattle.hc = _get_rand_between(0, 2)

	return newBattle

			
func calculate_encounter_outcome(camp): #pass in the entire camp object
	#use duration to determine how many encounters (battles) happen
	#duration comes in as seconds, so divide by 60 to make it 1 encounter per minute
	var encounterQuantity = camp.selectedDuration / 60
	#generate N battles and save their outcomes to the battleRecord
	#save cumulative loot totals to encounterOutcome
	for encounter in encounterQuantity:
		var battleOutcome = _calculate_battle_outcome(camp.heroes, camp.mobs)
		encounterOutcome.battleRecord.append(battleOutcome)
		encounterOutcome.lootTotal.append(battleOutcome["loot"])
		encounterOutcome.scTotal += battleOutcome["sc"]
		encounterOutcome.hcTotal += battleOutcome["hc"]
	return encounterOutcome