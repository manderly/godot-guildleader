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

#populate battleRecord array with battle objects
#populate loot with names of items won
#populate sc and hc with totals of currency won 
var encounterOutcome = {
	"battleRecord":[],
	"lootTotal":[],
	"scTotal":0,
	"hcTotal":0,
	"summary":[]
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
	var battleMobsQuantity = _get_rand_between(1, 5)
	#now figure out which mobs those are, exactly
	#todo: use rarities as designed in the data sheet (right now they are all equally likely) 
	var randomMob = null
	for i in battleMobsQuantity:
		var randMobNum = _get_rand_between(1, 3) #never picks 2 if you pass it (0,2)
		randomMob = mobs[randMobNum - 1]
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
	print(targetMob.mobName + " died!")
	for hero in newBattle.heroes:
		hero.give_xp(15) #todo: formula someday 
	newBattle.mobs.erase(targetMob)
	print("awarding SC and HC loot for this mob")
	newBattle.sc = _get_rand_between(1, 100)
	newBattle.hc = _get_rand_between(0, 2)
	
func _calculate_battle_outcome(heroes, mobTable):
	#a battle continues until all mobs (or all heroes) are dead
	#if all heroes die, the encounter is over
	#if all mobs die, the encounter goes onto the next battle 
	
	#figure out which mobs and which heroes are going to participate in this fight
	var randomMobs = _get_battle_mobs(mobTable)
	var livingHeroes = []
	for hero in heroes:
		if (hero && !hero.dead):
			livingHeroes.append(hero)
	var newBattle = {
		#contains actual hero objects and actual mob objects
		"heroes":livingHeroes,
		"mobs":randomMobs,
		"winner":"",
		"loot":null,
		"sc":0,
		"hc":0,
		"xp:":0,
		"rawBattleLog":[]
	}
	
	while (newBattle.mobs.size() > 0):
		print("living mobs: " + str(randomMobs.size()))
		var targetMob = null
		#everyone takes a turn (todo: shuffle the arrays or sort by initiatve rolls)
		for hero in newBattle.heroes:
			if (!hero.dead):
				if (hero.heroClass == "Warrior" || hero.heroClass == "Rogue" || hero.heroClass == "Ranger"):
					targetMob = _get_target_entity(newBattle.mobs)
					print(hero.heroName + " is going to attack " + targetMob.mobName)
					var unmodifiedDamage = hero.melee_attack()
					targetMob.hpCurrent -= unmodifiedDamage
					#see if mob should die 
					if targetMob.hpCurrent <= 0:
						_target_mob_dies(targetMob, newBattle)
						if (randomMobs.size() == 0):
							break
				elif (hero.heroClass == "Wizard"):
					#nuke
					targetMob = _get_target_entity(randomMobs)
					var nukeDmg = hero.level * hero.intelligence
					print(hero.heroName + " nukes " + targetMob.mobName + " for " + str(nukeDmg) + " points of damage")
					targetMob.hpCurrent -= nukeDmg
					if targetMob.hpCurrent <= 0:
						_target_mob_dies(targetMob, newBattle)
						if (randomMobs.size() == 0):
							break
				elif (hero.heroClass == "Cleric"):
					#heal ALL heroes in party
					for partyMember in livingHeroes:
						if (!partyMember.dead):
							print(hero.heroName + " restores 5 hitpoints to everyone, including: " + partyMember.heroName)
							partyMember.hpCurrent += 5
							if (partyMember.hpCurrent > partyMember.hp):
								partyMember.hpCurrent = partyMember.hp #cannot exceed max 
				elif (hero.heroClass == "Druid"):
					#can nuke or heal, for now druid just heals lowest hp hero 
					var lowestHPhero = livingHeroes[0]
					for partyMember in livingHeroes:
						if (!partyMember.dead && partyMember.hpCurrent < lowestHPhero.hpCurrent):
							lowestHPhero = partyMember
					#now we know which hero is in most need of healing
					print(hero.heroName + " restores 15 hitpoints to " + lowestHPhero + " with a 5 hp bonus")
					lowestHPhero.hpCurrent += 15
					if (lowestHPhero.hpCurrent > lowestHPhero.hp):
						lowestHPhero.hpCurrent = (lowestHPhero.hp + 5) #give a litle extra on top
			else:
				print("this hero is dead")
				
		for mob in randomMobs:
			var targetHero = _get_target_entity(livingHeroes)
			if (!mob.dead):
				print(mob.mobName + " is going to attack " + targetHero.heroName)
				var unmodifiedDamage = mob.dps * mob.strength * mob.level
				targetHero.hpCurrent -= unmodifiedDamage
				if targetHero.hpCurrent == 0:
					targetHero.dead = true
					print(targetHero.heroName + " died!")
			else:
				print("this mob is dead")


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
	#the summary is shown on the results page, but there is also a more detailed battle log to view
	encounterOutcome.summary.append("There were " + str(encounterQuantity) + " battles.")
	for hero in camp.heroes:
		if (hero):
			encounterOutcome.summary.append(hero.heroName + " is still alive.")
	return encounterOutcome