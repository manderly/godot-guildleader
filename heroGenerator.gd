extends Node
#heroGenerator.gd
#makes a level 1 hero with random class and name

var nameGenerator = load("res://nameGenerator.gd").new()

func _ready():
	pass

#make new hero object
func generate(destinationArray, classStr):
	var newHero = load("res://hero.gd").new()
	newHero.heroID = global.nextHeroID
	global.nextHeroID += 1
	
	#random gender (they're all female by default, but if we roll a 1, change to male)
	#this is only used to get a name that sounds somewhat masculine or feminine, no effect on gameplay
	var randomGender = randi()%2 #0 or 1
	if (randomGender == 1):
		newHero.gender = "male"
	
	#random head (these are gendered mostly so we don't end up with bearded ladies)
	if (newHero.gender == "female"):
		newHero.headSprite = newHero.humanFemaleHeads[randi() % newHero.humanFemaleHeads.size()]
	else:
		newHero.headSprite = newHero.humanMaleHeads[randi() % newHero.humanMaleHeads.size()]
		
	#random class
	var randomClass = randi()%3+1 #1-4
	
	if (classStr == "Wizard"):
		newHero.charClass = "Wizard"
		newHero.archetype = "Caster"
		newHero.give_gear_loadout("wizard12")  #"wizardNew")
		#we need better wizards, here's a twinked one:
		#newHero.give_gear_loadout("wizardUber")
			
	elif (classStr == "Rogue"):
		newHero.charClass = "Rogue"
		newHero.archetype = "Melee"
		newHero.give_gear_loadout("rogue12") #"rogueNew")

	elif (classStr == "Warrior"):
		newHero.charClass = "Warrior"
		newHero.archetype = "Melee"
		newHero.give_gear_loadout("warrior12") #"warriorNew")
	
	elif (classStr == "Ranger"):
		newHero.charClass = "Ranger"
		newHero.archetype = "Melee"
		newHero.give_gear_loadout("ranger12")
		
	elif (classStr == "Cleric"):
		newHero.charClass = "Cleric"
		newHero.archetype = "Support"
		newHero.give_gear_loadout("cleric12")

	elif (classStr == "Druid"):
		newHero.charClass = "Druid"
		newHero.archetype = "Support"
		newHero.give_gear_loadout("druidNew")
			
	else:
		print("ERROR - BAD HERO CLASS TYPE")
		
	#random name 
	#todo: pass species in addition to gender 
	newHero.set_first_name(nameGenerator.generateFirst(newHero.gender))
	newHero.set_last_name(nameGenerator.generateLast(newHero.charClass))
	
	var startingStats = staticData.heroStats[newHero.charClass.to_lower()]
	#assign stats accordingly
	newHero.baseHp = startingStats["hp"]
	newHero.baseMana = startingStats["mana"]
	newHero.baseDps = startingStats["dps"]
	newHero.baseArmor = 0
	newHero.baseStrength = startingStats["strength"]
	newHero.baseDefense = startingStats["defense"]
	newHero.baseIntelligence = startingStats["intelligence"]
	newHero.baseRegenRateHP = startingStats["regenRateHP"]
	newHero.baseRegenRateMana = startingStats["regenRateMana"]
	newHero.baseCriticalHitChance = 0
	newHero.baseSkillAlchemy = 0
	newHero.baseSkillBlacksmithing = 0
	newHero.baseSkillChronomancy = 0
	newHero.baseSkillFletching = 0
	newHero.baseSkillJewelcraft = 0
	newHero.baseSkillTailoring = 0
	newHero.baseSkillHarvesting = 0
	newHero.baseDrama = startingStats["drama"]
	newHero.baseMood = startingStats["mood"]
	newHero.basePrestige = startingStats["prestige"]
	newHero.baseGroupBonus = startingStats["groupBonus"]
	newHero.baseRaidBonus = startingStats["raidBonus"]

	#other aspects of a hero 
	newHero.atHome = true
	newHero.level = 1
	newHero.perkPoints = 0
	newHero.xp = 0
	newHero.isPlayer = false
	newHero.entityType = "hero"
	newHero.showMyHelm = true

	if (destinationArray == global.guildRoster):
		newHero.currentRoom = 1 #inside (0 by default - outside)
		newHero.recruited = true #false by default 
	else: #this is an unrecruited hero
		newHero.currentRoom = 0
		newHero.recruited = false
		var randLevel = randi()%3+1
		newHero.make_level(randLevel)
		var gearRand1 = randi()%3+1
		
		#todo: may be a bad idea to generate these items with IDs since the user doesn't own them yet
		#IDs are really just for items the player owns 
		newHero.give_new_item("Muddy Boots") #everyone should start with shoes of some kind...

		if (gearRand1 == 1):
			newHero.give_new_item("Cloth Shirt")
			newHero.give_new_item("Worn Canvas Sandals")
		elif (gearRand1 == 2):
			newHero.give_new_item("Simple Ring")
		else:
			newHero.give_new_item("Cloth Shirt")
			newHero.give_new_item("Simple Ring")
	
	#build perks object out of which perks this hero can actually use
	for key in staticData.perks.keys():
		if (staticData.perks[key].restriction == "any" ||
			staticData.perks[key].restriction.to_lower() == newHero.archetype.to_lower() ||
			staticData.perks[key].restriction.to_lower() == newHero.charClass.to_lower()):
			#check if it's for anyone, this hero's archetype, or this hero's class
			#if so, give this hero this perk option 
			newHero.perks[key] = staticData.perks[key].duplicate()
	
	newHero.update_hero_stats() #calculate hp, mana, etc.
	newHero.hpCurrent = newHero.hp #only do this when we generate a hero (that's why it's not in update_hero_stats)
	newHero.manaCurrent = newHero.mana
	destinationArray.append(newHero)
