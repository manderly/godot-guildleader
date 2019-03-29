extends Node
var mobGenerator = load("res://mobGenerator.gd").new()
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
				"detailedPlayByPlay":[],
				"vignetteData":{
					"campHeroes":[],
					"battleSnapshots":[],
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
		
func _get_random_battle_order(heroes, mobs):
	var heroesAndMobs = [];
	# could be like hero1, hero3, mob2, mob1, hero2, mob3
	for entity in heroes:
		heroesAndMobs.append(entity)
	
	for entity in mobs:
		heroesAndMobs.append(entity)
		
	var shuffledHeroesAndMobs = []
	var indexList = range(heroesAndMobs.size())
	for i in range(heroesAndMobs.size()):
		var x = randi()%indexList.size()
		shuffledHeroesAndMobs.append(heroesAndMobs[indexList[x]])
		indexList.remove(x)
		
	return shuffledHeroesAndMobs

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
		if (hero.level > targetMob.level + 5):
			# no xp
			encounter.detailedPlayByPlay.append(hero.heroFirstName + " is too high level to get any xp from this enemy.")
		else:
			# hero is either 4 levels over the mob or lower level than the mob
			if (hero.level + 2 < targetMob.level):
				# give bonus xp if hero is 3 levels (or more) below this mob
				xp += (targetMob.level * 2)
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
	if (lootTable.scMax > 0):
		var scAmount = _get_rand_between(lootTable.scMin, lootTable.scMax)
		encounter.detailedPlayByPlay.append("Looted " + str(scAmount) + " coins.")
		#newBattle.rawBattleLog.append("Looted this much SC: " + str(scAmount))
		newBattle.sc = scAmount
	else:
		newBattle.sc = 0
	
	#delete this mob from the current fight
	newBattle.mobs.erase(targetMob)
	_remove_from_battle_order(targetMob)
	#encounterOutcome.detailedPlayByPlay.append("Looted this item: " + lootTable.item1)
	#newBattle.rawBattleLog.append("The heroes looted: " + str(newBattle.sc) + " coins") 
	
func _print_battle_order():
	print("BATTLE ORDER:")
	var i = 0;
	for entity in battleOrder:
		#print(entity.entityType)
		if (entity.entityType == "mob"):
			print(str(i) + " " + entity.mobName + " level " + str(entity.level))
		elif (entity.entityType == "hero"):
			print(str(i) + " " + entity.heroFirstName + " level " + str(entity.level) + " " + entity.charClass)
		
		i += 1
		
func _remove_from_battle_order(entity):
	for entity in battleOrder:
		if (entity.entityType == "mob"):
			if (entity.mobName == entity.mobName && entity.hpCurrent <= 0):
				#print("removing from battle order: " + entity.mobName)
				battleOrder.erase(entity)
		elif (entity.entityType == "hero"):
			if (entity.heroFirstName == entity.heroFirstName && entity.hpCurrent <= 0):
				#print("removing from battle order: " + entity.heroFirstName)
				battleOrder.erase(entity)
	
	#_print_battle_order()
	
func _calculate_battle_outcome(camp):
	var heroes = camp.heroes
	var spawnPointData = camp.spawnPointData
	
	encounter.detailedPlayByPlay.append("NEW BATTLE! Battle #" + str(battleNumber))
	
	# for THIS BATTLE, create an object that will hold the 'before' and 'after' snapshots
	# of hero and mob hp 
	# also contains all mob instance data so we can draw them on the screen during the vignette
	var battleSnapshot = {
		"heroDeltas":{},
		"mobs":[],
		"mobDeltas":{}
	}

	
	# Next, refill hp and mana based on hero's regen rate and the camp's respawn rate

	# Every hero has a regenRateHP and regenRateMana expressed as an int (1, 5, 20, etc)
	
	# And every battle has a respawn time that represents the wait between fights
	# Heroes refill hp and mana in that time
	# The higher the wait time and the higher the regen rate, the more hp and mana recovered
	# before the next fight
	
	for hero in heroes:
		# regen hp and mana every X (global.tickRate) seconds of downtime (respawnRate)
		hero.regen_hp_between_battles(camp.respawnRate)
		hero.regen_mana_between_battles(camp.respawnRate) #hero.regenRateMana * (camp.respawnRate / 10)
			
		# Now that we're done regenning, make a snapshot of this hero's data for the vignette
		battleSnapshot.heroDeltas[hero.heroID] = {
				"startHP":hero.hpCurrent,
				"endHP":0,
				"totalHP":hero.hp,
				"startMana":hero.manaCurrent,
				"endMana":0,
				"totalMana":hero.mana
			}
		
	#a battle continues until all mobs (or all heroes) are dead
	#if all heroes die, the encounter is over
	#if all mobs die, the encounter goes onto the next battle 
	
	#figure out which mobs and which heroes are going to participate in this fight
	var randomMobs = _get_battle_mobs(spawnPointData)
	
	# preserve these mobs for all time in the battle snapshots
	# hopefully they don't get blown out by erasing them elsewhere... probably do though 
	for mob in randomMobs:
		battleSnapshot.mobs.append(mob)
		
	if (randomMobs.size() > 1):
		encounter.detailedPlayByPlay.append(str(randomMobs.size()) + " enemies enter the fight.")
	else:
		encounter.detailedPlayByPlay.append(str(randomMobs.size()) + " enemy enters the fight.")
	for mob in randomMobs:
		encounter.detailedPlayByPlay.append("*" + mob.mobName + " (Level " + str(mob.level) + " HP: " + str(mob.hpCurrent) + ")")
	for hero in heroes:
		encounter.detailedPlayByPlay.append(">" + hero.heroFirstName + " (Level " + str(hero.level) + " " + hero.charClass + " HP: " + str(hero.hpCurrent) + ")")
		
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":heroes,
		"mobs":randomMobs,
		"winner":"",
		"loot":[], #item name strings 
		"sc":0,
		"xp:":0,
		"rawBattleLog":[]
	}
	
	# shuffle mobs and heroes into random order 
	battleOrder = _get_random_battle_order(newBattle.heroes, newBattle.mobs)
	
		#if ("mobName" in entity):
		#	print(entity.mobName)
	
	#while there are still mobs and heroes alive, pick next in battleOrder
	# this system is built on the assumption that battleOrder and newBattle.heroes/mobs
	# reference the same entities in memory (passed by reference)
	
	var i = 0
	while (newBattle.mobs.size() > 0 && newBattle.heroes.size() > 0):
		
		if (i >= battleOrder.size()):
			i = 0
			
		var entity = battleOrder[i]
		i+=1
		
		#entity.say_hello()
		if (entity.entityType == "mob"):
			# only pick a hero to fight if any are left 
			if (newBattle.heroes.size() > 0):
				var mob = entity
				#this mob's target (randomly picked for now)
				var targetHero = _get_target_entity(newBattle.heroes) #crashes when there are null spots in hero array
				var unmodifiedDamage = mob.get_melee_attack_damage()
				targetHero.take_melee_damage(unmodifiedDamage, mob.level)
				encounter.detailedPlayByPlay.append(mob.mobName + " attacks " + targetHero.heroFirstName + " for " + str(unmodifiedDamage) + " points of damage")
				
				if (targetHero.hpCurrent <= 0):
					targetHero.set_dead()
					targetHero.send_home()
					encounter.detailedPlayByPlay.append(targetHero.heroFirstName + " died!")
					newBattle.heroes.erase(targetHero)
					_remove_from_battle_order(targetHero)
					if (newBattle.heroes.size() == 0):
						encounter.detailedPlayByPlay.append("Total party wipe!")
						break
			else:
				encounter.detailedPlayByPlay.append("Total party wipe!")
				print("no heroes left to fight, the encounter is over")
				break
		elif (entity.entityType == "hero"):
			var hero = entity
			#get an enemy target
			var targetMob = null
			targetMob = _get_target_entity(newBattle.mobs)

			if (hero.charClass == "Warrior" || hero.charClass == "Rogue" || hero.charClass == "Ranger"):
				var unmodifiedDamage = hero.melee_attack()
				targetMob.take_melee_damage(unmodifiedDamage, hero.level)
				encounter.detailedPlayByPlay.append(hero.heroFirstName + " attacked " + targetMob.mobName + " for " + str(unmodifiedDamage) + " points of damage")

				#see if mob should die 
				if targetMob.hpCurrent <= 0:
					_target_mob_dies(targetMob, newBattle)
					if (newBattle.mobs.size() == 0):
						break
			elif (hero.charClass == "Wizard"):
				#nuke
				var nukeDmg = hero.get_nuke_dmg()
				var mobBaseResist = targetMob.get_base_resist(hero.level)

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
						targetMob.take_spell_damage(modifiedNukeDmg)
						
				else:
					#full damage
					encounter.detailedPlayByPlay.append(hero.heroFirstName + " nukes " + targetMob.mobName + " for " + str(nukeDmg) + " points of damage!")
					targetMob.take_spell_damage(nukeDmg)
				
				if targetMob.hpCurrent <= 0:
					_target_mob_dies(targetMob, newBattle)
					if (newBattle.mobs.size() == 0):
						break
			elif (hero.charClass == "Cleric"):
				#heal ALL heroes in party
				var healAmount = hero.get_cleric_party_heal_amount()
				#_heal_all_heroes(healAmount)
				for partyMember in newBattle.heroes:
					if (!partyMember.dead):
						encounter.detailedPlayByPlay.append(hero.heroFirstName + " restores " + str(healAmount) + " hitpoints to " + partyMember.heroFirstName + "!")
						partyMember.get_healed(healAmount)
			elif (hero.charClass == "Druid"):
				#can nuke or heal, for now druid just heals lowest hp hero 
				var lowestHPhero = newBattle.heroes[0]
				for partyMember in newBattle.heroes:
					if (!partyMember.dead && partyMember.hpCurrent < lowestHPhero.hpCurrent):
						lowestHPhero = partyMember
				#now we know which hero is in most need of healing
				var healAmount = hero.get_druid_target_heal_amount()
				#print(hero.heroFirstName + " restores " + healAmount + " hitpoints to " + lowestHPhero + " with 5 hp bonus on top")
				lowestHPhero.get_healed(healAmount)
				lowestHPhero.hpCurrent += 5 # little extra on top ok to exceed capacity
		else:
			print("encounterGenerator.gd - entity type " + entity.entityType + " not found")
	battleNumber += 1
	
	for hero in heroes:
		# make a snapshot of this hero's data for the vignette
		# end hp is 0 by default, so if a hero no longer exists in heroes (because it is dead)
		# then that 0 will remain in place 
		battleSnapshot.heroDeltas[hero.heroID].endHP = hero.hpCurrent
		battleSnapshot.heroDeltas[hero.heroID].endMana = hero.manaCurrent

	encounter.vignetteData.battleSnapshots.append(battleSnapshot)
	return newBattle

			
func calculate_encounter_outcome(camp): #pass in the entire camp object
	#use duration and respawn rate to determine how many encounters (battles) happen
	# camp respawnRate comes in as seconds, such as "60 seconds between battles"
	encounter.vignetteData.respawnRate = camp.respawnRate
	
	var battleQuantity = camp.selectedDuration / camp.respawnRate
	print("encounterGenerator.gd line 384 BATTLE QUANTITY: " + str(battleQuantity))
	
	#so the vignette knows which heroes were here
	for hero in camp.heroes:
		encounter.vignetteData.campHeroes.append(hero)
	
	var battlesComplete = 0
	while (battlesComplete < battleQuantity && camp.heroes.size() > 0):
		var battleOutcome = _calculate_battle_outcome(camp)
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