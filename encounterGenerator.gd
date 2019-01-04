extends Node
var mobGenerator = load("res://mobGenerator.gd").new()
# encounterGenerator.gd 

# Terminology: 
# an encounter is the entire thing
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
#populate sc and hc with totals of currency won 
#class Outcome: 

	
var heroesClone = []
var battleNumber = 1

#var encounter = null #instantiate in _ready
var encounter = {
				"battleRecord":[],
				"lootedItemsNames":[],
				"scTotal":-1,
				"summary":[],
				"detailedPlayByPlay":[]
			}

#todo: track how much xp each hero gets individually for display later 

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#encounter = Outcome.new()
	#print(encounter.outcome)
	pass

func _get_rand_between(firstVal, secondVal):
	var bottom = firstVal
	var top = secondVal
	
	if (secondVal < firstVal): #figure out which value is lower (ie: if we pass (8,0) we can't use them as-is) 
		bottom = secondVal
		top = firstVal
	
	var randNum = randi()%int(top)+int(bottom) #1-100, 5-10, 600-1900, etc
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

func _get_target_entity(targets):
	if (targets.size()):
		var target = targets[randi()%targets.size()]
		return target
	else: 
		print("ERROR: NOTHING TO PICK FROM")

#modifies the current newBattle object directly
func _target_mob_dies(targetMob, newBattle):
	targetMob.dead = true
	encounter.detailedPlayByPlay.append(targetMob.mobName + " was defeated!")
	#newBattle.rawBattleLog.append(targetMob.mobName + " was defeated!")
	
	#give xp
	#todo: some fancy formula here
	#for now, just use the mob's level x 2 x 2 again
	var xp = ((targetMob.level * int(2)) * int(2) + 15)
	
	for hero in newBattle.heroes:
		hero.give_xp(round(xp/newBattle.heroes.size())) #todo: formula someday
		if (hero.xp > staticData.levelXpData[str(hero.level)].total):
			hero.xp = staticData.levelXpData[str(hero.level)].total
			encounter.detailedPlayByPlay.append(hero.heroFirstName + " is full xp and ready to train.")
		else:
			encounter.detailedPlayByPlay.append(hero.heroFirstName + " got " + str(xp/newBattle.heroes.size()) + " xp!")

		
	#give loot (randomly determined from loot table)
	var lootTable = staticData.lootTables[targetMob.lootTable]
	
	#determine the upper limit based on how long the camp is expected to last
	#shorter camps have a slightly greater chance of dropping items
	#longer camps have a slightly lower chance of dropping items 
	if (_get_rand_between(0, 100) < lootTable.item1Chance):
		#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item1)
		encounter.detailedPlayByPlay.append("Looted this item: " + lootTable.item1)
		newBattle.loot.append(lootTable.item1)
		
	if (_get_rand_between(0, 100) < lootTable.item2Chance):
		#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item2)
		encounter.detailedPlayByPlay.append("Looted this item: " + lootTable.item2)
		newBattle.loot.append(lootTable.item2)
		
	#Determine how much SC the player looted from this mob
	#Not every mob drops money, so don't roll a random if this mob is moneyless 
	newBattle.hc = _get_rand_between(0, 2)
	if (lootTable.scMax > 0):
		var scAmount = _get_rand_between(lootTable.scMin, lootTable.scMax)
		encounter.detailedPlayByPlay.append("Looted " + str(scAmount) + " coins.")
		#newBattle.rawBattleLog.append("Looted this much SC: " + str(scAmount))
		newBattle.sc = scAmount
	else:
		newBattle.sc = 0
	
	#delete this mob from the current fight
	newBattle.mobs.erase(targetMob)
	#encounterOutcome.detailedPlayByPlay.append("Looted this item: " + lootTable.item1)
	#newBattle.rawBattleLog.append("The heroes looted: " + str(newBattle.sc) + " coins") 
	
func _calculate_battle_outcome(heroes, spawnPointData):
	encounter.detailedPlayByPlay.append("NEW BATTLE! Battle #" + str(battleNumber))
	#regen heroes
	#todo: better regen formula
	for hero in heroes:
		hero.hpCurrent += (_get_rand_between(1,10))
		if (hero.hpCurrent > hero.hp):
			hero.hpCurrent = hero.hp
	
	#a battle continues until all mobs (or all heroes) are dead
	#if all heroes die, the encounter is over
	#if all mobs die, the encounter goes onto the next battle 
	
	#figure out which mobs and which heroes are going to participate in this fight
	var randomMobs = _get_battle_mobs(spawnPointData)
	if (randomMobs.size() > 1):
		encounter.detailedPlayByPlay.append(str(randomMobs.size()) + " enemies enter the fight.")
	else:
		encounter.detailedPlayByPlay.append(str(randomMobs.size()) + " enemy enters the fight.")
	for mob in randomMobs:
		encounter.detailedPlayByPlay.append("*" + mob.mobName + " (Level " + str(mob.level) + " HP: " + str(mob.hpCurrent) + ")")
	for hero in heroes:
		encounter.detailedPlayByPlay.append(">" + hero.heroFirstName + " (Level " + str(hero.level) + " " + hero.heroClass + " HP: " + str(hero.hpCurrent) + ")")
		
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":heroes,
		"startMobsSprites":[],
		"mobs":randomMobs,
		"winner":"",
		"loot":[], #item name strings 
		"sc":0,
		"hc":0,
		"xp:":0,
		"rawBattleLog":[]
	}
	
	for mob in newBattle.mobs:
		newBattle.startMobsSprites.append(mob.sprite)
	
	while (newBattle.mobs.size() > 0 && newBattle.heroes.size() > 0):
		#everyone takes a turn (todo: shuffle the arrays or sort by initiatve rolls)
		for hero in newBattle.heroes:
			var targetMob = null
			targetMob = _get_target_entity(newBattle.mobs)
		
			if (hero && !hero.dead):
				if (hero.heroClass == "Warrior" || hero.heroClass == "Rogue" || hero.heroClass == "Ranger"):
					var unmodifiedDamage = hero.melee_attack()
					targetMob.hpCurrent -= int(unmodifiedDamage)
					encounter.detailedPlayByPlay.append(hero.heroFirstName + " attacked " + targetMob.mobName + " for " + str(unmodifiedDamage) + " points of damage")
					#todo: mob's defense roll 
					#see if mob should die 
					if targetMob.hpCurrent <= 0:
						_target_mob_dies(targetMob, newBattle)
						if (newBattle.mobs.size() == 0):
							break
				elif (hero.heroClass == "Wizard"):
					#nuke
					var nukeDmg = hero.level * hero.intelligence
					
					#mob's save roll is based on level difference between hero and mob
					#if mob > hero, mob has a greater chance to resist
					#if mob < hero, mob has a lesser chance to resist
					var mobBaseResist = targetMob.baseResist #out of 20
					
					if (hero.level > targetMob.level):
						mobBaseResist -= (hero.level - targetMob.level)
						if mobBaseResist < 1:
							mobBaseResist = 1
					elif (hero.level < targetMob.level):
						mobBaseResist += (targetMob.level - hero.level)
						if mobBaseResist > 19:
							mobBaseResist = 19

					#now roll to see if the mob resists some of the spell dmg
					var resistRoll = _get_rand_between(0, 20)
					if (resistRoll <= mobBaseResist):
						#mob resists the nuke
						#but how bad is the resist?
						#only get a full resist if the mob is higher level than the player
						if (targetMob.level > hero.level):
							#full resist
							encounter.detailedPlayByPlay.append(hero.heroFirstName + " attempted to nuke " + targetMob.mobName + ", but " + targetMob.mobName + " resisted!")
						else:
							#partial resist because hero is higher level than mob
							var resistRand = _get_rand_between(1, targetMob.baseResist+1)
							var modifiedNukeDmg = (nukeDmg / resistRand)
		
							encounter.detailedPlayByPlay.append(hero.heroFirstName + " nukes " + targetMob.mobName + " for " + str(modifiedNukeDmg) + " points of damage! (Partial resist)")
							targetMob.hpCurrent -= int(modifiedNukeDmg)
					else:
						#full damage
						encounter.detailedPlayByPlay.append(hero.heroFirstName + " nukes " + targetMob.mobName + " for " + str(nukeDmg) + " points of damage!")
						targetMob.hpCurrent -= int(nukeDmg)
					
					if targetMob.hpCurrent <= 0:
						_target_mob_dies(targetMob, newBattle)
						if (newBattle.mobs.size() == 0):
							break
				elif (hero.heroClass == "Cleric"):
					#heal ALL heroes in party
					var healAmount = 16 #todo: fancy formula
					for partyMember in newBattle.heroes:
						if (!partyMember.dead):
							encounter.detailedPlayByPlay.append(hero.heroFirstName + " restores " + str(healAmount) + " hitpoints to " + partyMember.heroFirstName + "!")
							#if (battlePrint):
								#print(hero.heroFirstName + " restores 5 hitpoints to everyone, including: " + partyMember.heroFirstName)
							partyMember.hpCurrent += healAmount
							if (partyMember.hpCurrent > partyMember.hp):
								partyMember.hpCurrent = partyMember.hp #cannot exceed max 
				elif (hero.heroClass == "Druid"):
					#can nuke or heal, for now druid just heals lowest hp hero 
					var lowestHPhero = newBattle.heroes[0]
					for partyMember in newBattle.heroes:
						if (!partyMember.dead && partyMember.hpCurrent < lowestHPhero.hpCurrent):
							lowestHPhero = partyMember
					#now we know which hero is in most need of healing
					print(hero.heroFirstName + " restores 15 hitpoints to " + lowestHPhero + " with a 5 hp bonus")
					lowestHPhero.hpCurrent += 15
					if (lowestHPhero.hpCurrent > lowestHPhero.hp):
						lowestHPhero.hpCurrent = (lowestHPhero.hp + 5) #give a litle extra on top
		
		#now the mobs get a turn, but only if there's some heroes left
		for mob in newBattle.mobs:
			#var heroesToFight = _get_target_entity(newBattle.heroes)
			if (newBattle.heroes.size() > 0):
				#this mob's target (randomly picked for now)
				var targetHero = _get_target_entity(newBattle.heroes) #crashes when there are null spots in hero array
				var unmodifiedDamage = mob.dps * mob.strength * mob.level
				targetHero.hpCurrent -= unmodifiedDamage
				encounter.detailedPlayByPlay.append(mob.mobName + " attacks " + targetHero.heroFirstName + " for " + str(unmodifiedDamage) + " points of damage")
				if (targetHero.hpCurrent <= 0):
					targetHero.dead = true
					targetHero.hpCurrent = 0
					targetHero.manaCurrent = 0
					targetHero.send_home()
					encounter.detailedPlayByPlay.append(targetHero.heroFirstName + " died!")
					newBattle.heroes.erase(targetHero)
					if (newBattle.heroes.size() == 0):
						encounter.detailedPlayByPlay.append("Total party wipe!")
						break
			else:
				encounter.detailedPlayByPlay.append("Total party wipe!")
				print("no heroes left to fight, the encounter is over")
				break

	battleNumber += 1
	return newBattle

			
func calculate_encounter_outcome(camp): #pass in the entire camp object
	#use duration to determine how many encounters (battles) happen
	#duration comes in as seconds, so divide by 60 to make it 1 encounter per minute
	#or 120 to make it 1 encounter every 2 mins, etc.
	#remember that an encounter has several mobs in it
	#so pace these accordingly (maybe one encounter every 5-10 mins is ideal)
	
	var battleQuantity = 0
	
	#encounter = {} #load("res://CampOutcome.gd").new() #Outcome.new()
	#rather than determine battle quantity here, we should let the mob spawn rate determine it
	
	battleQuantity = camp.selectedDuration / (5 * 100)
	#generate N battles and save their outcomes to the battleRecord
	#save cumulative loot totals to encounterOutcome
	
	#heroesClone = []
	#for t in camp.heroes:
	#	if (t):
	#		heroesClone.append(t)
	
	var battlesComplete = 0
	while (battlesComplete < battleQuantity && camp.heroes.size() > 0):
		var battleOutcome = _calculate_battle_outcome(camp.heroes, camp.spawnPointData)
		battlesComplete += 1
		encounter.battleRecord.append(battleOutcome)
		
		for lootName in battleOutcome.loot:
			encounter.lootedItemsNames.append(lootName)
	
		encounter.scTotal += battleOutcome["sc"]
			
	#the summary is shown on the results page, but there is also a more detailed battle log to view
	if (battleNumber == 1 or battleNumber == 2):
		encounter.detailedPlayByPlay.append("There was 1 battle.")
		encounter.summary.append("There was 1 battle.")
	else:
		encounter.detailedPlayByPlay.append("There were " + str(battleNumber - 1) + " battles.")
		encounter.summary.append("There were " + str(battleNumber) + " battles.")
	
	if (camp.heroes.size() == 0):
		encounter.summary.append("Total party wipe!")
	else:
		for hero in camp.heroes:
		#hero.xp = global.levelXpData[hero.level].total
			if (hero && hero.xp == staticData.levelXpData[str(hero.level)].total):
				encounter.summary.append(hero.heroFirstName + " is ready to train!")
			else:
				encounter.summary.append(hero.heroFirstName + " survived!")
	
	return encounter