extends Node
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
var encounterOutcome = {
	"battleRecord":[],
	"lootedItemsNames":[], #just the names, no dupes 
	"scTotal":0,
	"summary":[],
	"detailedPlayByPlay":[]
}
var heroesClone = []
var battleNumber = 1

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
	
func _get_battle_mobs(mobs):
	#in a battle, it's all the available heroes vs. a random assortment of mobs
	var mobAssortment = []
	#eventually, we'll pass in a min and max quantity of mobs
	#but for now, 1-3 mobs will do
	var battleMobsQuantity = _get_rand_between(1, 2)
	#now figure out which mobs those are, exactly
	#todo: use rarities as designed in the data sheet (right now they are all equally likely) 
	var randomMob = null
	for i in battleMobsQuantity:
		var randMobNum = _get_rand_between(1,3) #never picks 2 if you pass it (0,2) (1,3)
		randomMob = mobs[randMobNum - 1] #[-1]
		randomMob.hpCurrent = randomMob.hp #reset HP 
		mobAssortment.append(randomMob)
	return mobAssortment

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
	encounterOutcome.detailedPlayByPlay.append(targetMob.mobName + " was defeated!")
	#newBattle.rawBattleLog.append(targetMob.mobName + " was defeated!")
	
	#give xp
	#todo: some fancy formula here
	#for now, just use the mob's level x 2 x 2 again
	var xp = ((targetMob.level * int(2)) * int(2) + 15)
	
	for hero in newBattle.heroes:
		hero.give_xp(round(xp/newBattle.heroes.size())) #todo: formula someday
		if (hero.xp > global.levelXpData[hero.level].total):
			hero.xp = global.levelXpData[hero.level].total
			encounterOutcome.detailedPlayByPlay.append(hero.heroName + " is full xp and ready to train.")
		else:
			encounterOutcome.detailedPlayByPlay.append(hero.heroName + " got " + str(xp/newBattle.heroes.size()) + " xp!")

		
	#give loot (randomly determined from loot table)
	var lootTable = global.lootTables[targetMob.lootTable]
	
	#determine the upper limit based on how long the camp is expected to last
	#shorter camps have a slightly greater chance of dropping items
	#longer camps have a slightly lower chance of dropping items 
	if (_get_rand_between(0, 100) < lootTable.item1Chance):
		#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item1)
		encounterOutcome.detailedPlayByPlay.append("Looted this item: " + lootTable.item1)
		newBattle.loot.append(lootTable.item1)
		
	if (_get_rand_between(0, 100) < lootTable.item2Chance):
		#newBattle.rawBattleLog.append("Looted this item: " + lootTable.item2)
		encounterOutcome.detailedPlayByPlay.append("Looted this item: " + lootTable.item2)
		newBattle.loot.append(lootTable.item2)
		
	#Determine how much SC the player looted from this mob
	#Not every mob drops money, so don't roll a random if this mob is moneyless 
	newBattle.hc = _get_rand_between(0, 2)
	if (lootTable.scMax > 0):
		var scAmount = _get_rand_between(lootTable.scMin, lootTable.scMax)
		encounterOutcome.detailedPlayByPlay.append("Looted " + str(scAmount) + " coins.")
		#newBattle.rawBattleLog.append("Looted this much SC: " + str(scAmount))
		newBattle.sc = scAmount
	else:
		newBattle.sc = 0
	
	#delete this mob from the current fight
	newBattle.mobs.erase(targetMob)
	#encounterOutcome.detailedPlayByPlay.append("Looted this item: " + lootTable.item1)
	#newBattle.rawBattleLog.append("The heroes looted: " + str(newBattle.sc) + " coins") 
	
func _calculate_battle_outcome(heroes, mobTable):
	encounterOutcome.detailedPlayByPlay.append("NEW BATTLE! Battle #" + str(battleNumber))
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
	var randomMobs = _get_battle_mobs(mobTable)
	if (randomMobs.size() > 1):
		encounterOutcome.detailedPlayByPlay.append(str(randomMobs.size()) + " enemies enter the fight.")
	else:
		encounterOutcome.detailedPlayByPlay.append(str(randomMobs.size()) + " enemy enters the fight.")
	for mob in randomMobs:
		encounterOutcome.detailedPlayByPlay.append("*" + mob.mobName + " (Level " + str(mob.level) + " HP: " + str(mob.hpCurrent) + ")")
	for hero in heroes:
		encounterOutcome.detailedPlayByPlay.append(">" + hero.heroName + " (Level " + str(hero.level) + " " + hero.heroClass + " HP: " + str(hero.hpCurrent) + ")")
		
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":heroes,
		"mobs":randomMobs,
		"winner":"",
		"loot":[], #item name strings 
		"sc":0,
		"hc":0,
		"xp:":0,
		"rawBattleLog":[]
	}
	
	while (newBattle.mobs.size() > 0 && newBattle.heroes.size() > 0):
		#everyone takes a turn (todo: shuffle the arrays or sort by initiatve rolls)
		for hero in newBattle.heroes:
			var targetMob = null
			targetMob = _get_target_entity(newBattle.mobs)
		
			if (hero && !hero.dead):
				if (hero.heroClass == "Warrior" || hero.heroClass == "Rogue" || hero.heroClass == "Ranger"):
					var unmodifiedDamage = hero.melee_attack()
					targetMob.hpCurrent -= int(unmodifiedDamage)
					encounterOutcome.detailedPlayByPlay.append(hero.heroName + " attacked " + targetMob.mobName + " for " + str(unmodifiedDamage) + " points of damage")
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
							encounterOutcome.detailedPlayByPlay.append(hero.heroName + " attempted to nuke " + targetMob.mobName + ", but " + targetMob.mobName + " resisted!")
						else:
							#partial resist because hero is higher level than mob
							var resistRand = _get_rand_between(1, targetMob.baseResist+1)
							var modifiedNukeDmg = (nukeDmg / resistRand)
		
							encounterOutcome.detailedPlayByPlay.append(hero.heroName + " nukes " + targetMob.mobName + " for " + str(modifiedNukeDmg) + " points of damage! (Partial resist)")
							targetMob.hpCurrent -= int(modifiedNukeDmg)
					else:
						#full damage
						encounterOutcome.detailedPlayByPlay.append(hero.heroName + " nukes " + targetMob.mobName + " for " + str(nukeDmg) + " points of damage!")
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
							encounterOutcome.detailedPlayByPlay.append(hero.heroName + " restores " + str(healAmount) + " hitpoints to " + partyMember.heroName + "!")
							#if (battlePrint):
								#print(hero.heroName + " restores 5 hitpoints to everyone, including: " + partyMember.heroName)
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
					print(hero.heroName + " restores 15 hitpoints to " + lowestHPhero + " with a 5 hp bonus")
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
				encounterOutcome.detailedPlayByPlay.append(mob.mobName + " attacks " + targetHero.heroName + " for " + str(unmodifiedDamage) + " points of damage")
				if (targetHero.hpCurrent <= 0):
					targetHero.dead = true
					encounterOutcome.detailedPlayByPlay.append(targetHero.heroName + " died!")
					newBattle.heroes.erase(targetHero)
					if (newBattle.heroes.size() == 0):
						encounterOutcome.detailedPlayByPlay.append("Total party wipe!")
						break
			else:
				encounterOutcome.detailedPlayByPlay.append("Total party wipe!")
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
	#lower level camps have slightly shorter durations to be more exciting
	
	#camps that last 1 hour or less have a 
	#higher spawn rate to encourage frequent play
	if (camp.selectedDuration <= 3600):
		battleQuantity = camp.selectedDuration / 400
	else:
		battleQuantity = camp.selectedDuration / 600
	#generate N battles and save their outcomes to the battleRecord
	#save cumulative loot totals to encounterOutcome
	
	heroesClone = []
	for t in camp.heroes:
		if (t):
			heroesClone.append(t)
	
	var battlesComplete = 0
	while (battlesComplete < battleQuantity && heroesClone.size() > 0):
		var battleOutcome = _calculate_battle_outcome(heroesClone, camp.mobs)
		battlesComplete += 1
		encounterOutcome.battleRecord.append(battleOutcome)
		
		for lootName in battleOutcome.loot:
			encounterOutcome.lootedItemsNames.append(lootName)
	
		encounterOutcome.scTotal += battleOutcome["sc"]
			
	#the summary is shown on the results page, but there is also a more detailed battle log to view
	if (battleNumber == 1):
		encounterOutcome.detailedPlayByPlay.append("There was " + str(battleNumber) + " battle.")
		encounterOutcome.summary.append("There was " + str(battleNumber) + " battle.")
	else:
		encounterOutcome.detailedPlayByPlay.append("There were " + str(battleNumber) + " battles.")
		encounterOutcome.summary.append("There were " + str(battleNumber) + " battles.")
		
	for hero in heroesClone:
		#hero.xp = global.levelXpData[hero.level].total
		if (hero && hero.xp == global.levelXpData[hero.level].total):
			encounterOutcome.summary.append(hero.heroName + " is ready to train!")
		else:
			encounterOutcome.summary.append(hero.heroName + " survived!")
			
	if (heroesClone.size() == 0):
		encounterOutcome.summary.append("Total party wipe!")
		
	return encounterOutcome