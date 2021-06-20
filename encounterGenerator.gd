extends Node
var mobGenerator = load("res://mobGenerator.gd").new()
var groupTarget = null

# encounterGenerator.gd 

# Terminology: 
# an encounter is the entire camp duration
# a battle is part of an encounter
# heroes win: heroes won the fight easily
# mobs win: heroes still win, technically, but we roll to see if any heroes die 

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

var battlePrint = false

#populate battleRecord array with battle objects
#populate loot with names of items won
#populate sc with totals of currency won 
#class Outcome: 

	
var heroesClone = []
var battleNumber = 1
var battleOrder = []

#var encounter = null #instantiate in _ready
var encounter = {
				"battleRecord":[],
				"lootedItemsNames":[],
				"scTotal":-1,
				"summary":[],
				"vignetteData":{
					"campHeroes":[],
					"campMobs":[],
					"respawnRate":0
				}
			}

#todo: track how much xp each hero gets individually for display later 

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#encounter = Outcome.new()
	#print(encounter.outcome)
	pass

func _get_rand_between(firstVal, secondVal):
	
	var minVal = firstVal
	var maxVal = secondVal
	
	if (secondVal < firstVal): #figure out which value is lower (ie: if we pass (8,0) we can't use them as-is) 
		minVal = secondVal
		maxVal = firstVal
	# random between 0 and 1 seems to be broken, always get 1
	var randNumRaw = randi()% ((maxVal - minVal) + 1) 
	var randNum = randNumRaw + minVal
	#print("getting random between " + str(firstVal) + " and " + str(secondVal) + ": " + str(randNum))
	
	if (randNum < minVal):
		print("ERROR! " + str(randNum) + " is less than boundary number " + str(minVal))
		randNum = minVal
		breakpoint
		
	if (randNum > maxVal):
		print("ERROR! " + str(randNum) + " is greater than boundary number " + str(maxVal))
		randNum = maxVal
		breakpoint

	return randNum
	
func _calculate_entity_score(entities):
	#use to determine a "score" value for a group of heroes or a group of mobs
	#super rudimentary right now, it just sums hp
	var hpTotal = 0
	for entity in entities:
		if (!entity.dead):
			hpTotal += entity.hp
	return hpTotal
	
	
func _get_random_mob_from_table(table):
	var mob = null
	var mobRand = _get_rand_between(0,100)

	if mobRand <= table.mob1Chance:
		mob = mobGenerator.get_mob(table.mob1)
	elif mobRand <= (table.mob1Chance + table.mob2Chance):
		mob = mobGenerator.get_mob(table.mob2)
	else:
		mob = mobGenerator.get_mob(table.mob3)
		
	mob.make_level(mob.level)
	return mob
	
func _get_battle_mobs(spawnPointData):
	#spawnPointData is an object containing table names for spawn points 1, 2, and 3
	#get the tables themselves
	var spawnPoint1Table = staticData.spawnTables[spawnPointData.spawnPoint1TableName]
	var spawnPoint2Table = staticData.spawnTables[spawnPointData.spawnPoint2TableName]
	var spawnPoint3Table = staticData.spawnTables[spawnPointData.spawnPoint3TableName]
	
	#in a battle, it's all the available heroes vs. a random assortment of mobs
	var spawnPoint1Mob = _get_random_mob_from_table(spawnPoint1Table)
	spawnPoint1Mob.hpCurrent = spawnPoint1Mob.hp
	var spawnPoint2Mob = _get_random_mob_from_table(spawnPoint2Table)
	spawnPoint2Mob.hpCurrent = spawnPoint2Mob.hp
	var spawnPoint3Mob = _get_random_mob_from_table(spawnPoint3Table)
	spawnPoint3Mob.hpCurrent = spawnPoint3Mob.hp
	
	var mobs = []
	
	mobs.append(spawnPoint1Mob)
	mobs.append(spawnPoint2Mob)
	mobs.append(spawnPoint3Mob)
	
	#randomMob.hpCurrent = randomMob.hp #reset HP 

	return mobs

func _calculate_average_level(entities):
	var sum = 0
	var average = 0
	for entity in entities:
		sum += entity.level
	average = sum/entities.size()
	return average
	
func calculate_encounter_xp_gains(camp):
	for hero in camp.heroes:
		if (hero.level > camp.level + 5):
			# no xp
			encounter.summary.append(hero.get_first_name() + " is too high level to get any xp from this camp.")
		else:
			# hero is either 4 levels over the mob or lower level than the mob
			if (hero.level + 2 < camp.level):
				# give bonus xp if hero is 3 levels (or more) below this mob
				hero.give_xp(100) #todo: formula someday
			
			if (hero.xp > staticData.levelXpData[str(hero.level)].total):
				hero.xp = staticData.levelXpData[str(hero.level)].total
				encounter.summary.append(hero.get_first_name() + " is full xp and ready to train.")
	
func calculate_encounter_mobs(camp):
	# camp data spreadhseet contains spawn tables for 3 distinct spawn points
	var spawnPoint1Table = staticData.spawnTables[camp.spawnPointData.spawnPoint1TableName]
	var spawnPoint2Table = staticData.spawnTables[camp.spawnPointData.spawnPoint2TableName]
	var spawnPoint3Table = staticData.spawnTables[camp.spawnPointData.spawnPoint3TableName]
	
	var mobs = []
	
	# for t in time, spawn mobs
	var t = 0;
	var adjustedCampDuration = camp.selectedDuration / 30
	while t < adjustedCampDuration:
		var spawnPoint1Mob = _get_random_mob_from_table(spawnPoint1Table)
		var spawnPoint2Mob = _get_random_mob_from_table(spawnPoint2Table)
		var spawnPoint3Mob = _get_random_mob_from_table(spawnPoint3Table)
	
		mobs.append(spawnPoint1Mob)
		mobs.append(spawnPoint2Mob)
		mobs.append(spawnPoint3Mob)
		t+=1
		
	return mobs
	
func calculate_encounter_loot(mobs):
	# for every mob that would've spawned, get some loot from it 
	# this might end up being too heavy of a calculation 
	for mob in mobs:
		var lootTable = staticData.lootTables[mob.lootTable]
		var lootGroup = staticData.lootGroups[lootTable.lootGroup]
		#Todo: determine the upper limit based on how long the camp is expected to last
		#shorter camps have a slightly greater chance of dropping items
		#longer camps have a slightly lower chance of dropping items 
		if (lootGroup != null):
			if (_get_rand_between(0,100) < lootTable.lootGroupChance):
				# we get to pick between X and Y random items from the lootGroup
				var quantityOfCommonItems = (_get_rand_between(lootTable.lootGroupMin, lootTable.lootGroupMax))
				#print("picking " + str(quantityOfCommonItems) + " common items (min: " + str(lootTable.lootGroupMin) + " max: " + str(lootTable.lootGroupMax) +")")
				if (quantityOfCommonItems > 0):
					for item in quantityOfCommonItems:
						# for now we're assuming all 11 items are stocked
						var itemRand = _get_rand_between(1,12) #between 1 and 12
						if (lootGroup["item"+str(itemRand)]):
							encounter.summary.append("Looted this item: " + lootGroup["item"+str(itemRand)])
							encounter.lootedItemsNames.append(lootGroup["item"+str(itemRand)])
						else:
							print("item " + str(itemRand) + " does not exist! check lootGroups.json!")
		else:
			print("ERROR: encounterGenerator.gd, line 220: lootGroup not found")
		
		if (_get_rand_between(0, 100) < lootTable.item1Chance):
			#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item1)
			encounter.summary.append("Looted this item: " + lootTable.campItem1)
			encounter.lootedItemsNames.append(lootTable.campItem1)
			
		if (_get_rand_between(0, 100) < lootTable.item2Chance):
			#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item2)
			encounter.summary.append("Looted this item: " + lootTable.campItem2)
			encounter.lootedItemsNames.append(lootTable.campItem2)
		
		#Determine how much SC the player looted from this mob
		#Not every mob drops money, so don't roll a random if this mob is moneyless 
		if (lootTable.scMax > 0):
			var scAmount = _get_rand_between(lootTable.scMin, lootTable.scMax)
			encounter.summary.append("Looted " + str(scAmount) + " coins.")
			#newBattle.rawBattleLog.append("Looted this much SC: " + str(scAmount))
			encounter.scTotal += scAmount
		else:
			encounter.scTotal += 0

func calculate_encounter_outcome(camp): 

	# build vignette data (used to build fight animation that plays during camp)
	for hero in camp.heroes:
		encounter.vignetteData.campHeroes.append(hero)
	
	var encounterMobs = calculate_encounter_mobs(camp)
	encounter.vignetteData.campMobs = encounterMobs
		
	# calculate the outcome (xp, rewards, loot, hero deaths)
	# problem is here, lootedItemNames is filled up by this method call 
	calculate_encounter_loot(encounterMobs)
	encounter.summary.append("The heroes camped " + camp.name + " for " + str(camp.selectedDuration))
	
	# formula here: hero xp is a lot if they're lower level than the camp, a little if they're higher level
	# hero xp is also based on how long they were out camping
	# heroes have a greater chance of wiping out if their levels are lower than mob levels
	# heroes have a lesser chance of wiping if balanced party present
	
	if (camp.heroes.size() == 0):
		encounter.summary.append("Total party wipe!")
	else:
		for hero in camp.heroes:
		#hero.xp = global.levelXpData[hero.level].total
			if (hero && hero.xp == staticData.levelXpData[str(hero.level)].total):
				encounter.summary.append(hero.get_first_name() + " is ready to train!")
			else:
				encounter.summary.append(hero.get_first_name() + " survived!")
	
	return encounter