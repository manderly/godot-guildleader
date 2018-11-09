extends Node
#heroGenerator.gd
#makes a level 1 hero with random class and name

var nameGenerator = load("res://nameGenerator.gd").new()
var humanFemaleHeads = ["human_female_01.png", "human_female_02.png", "human_female_03.png", "human_female_04.png", "human_female_05.png", "human_female_06.png", "human_female_07.png", "human_female_08.png", "human_female_09.png", "human_female_10.png", "human_female_11.png"]
var humanMaleHeads = ["human_male_01.png", "human_male_02.png", "human_male_03.png", "human_male_04.png", "human_male_05.png", "human_male_06.png", "human_male_07.png", "human_male_08.png", "human_male_08.png", "human_male_09.png"]
var elfFemaleHeads = ["elf_female_01.png"]

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
	
	#random name 
	#todo: pass species in addition to gender 
	newHero.heroName = nameGenerator.generate(newHero.gender)
	#random head (these are gendered mostly so we don't end up with bearded ladies)
	if (newHero.gender == "female"):
		newHero.headSprite = humanFemaleHeads[randi() % humanFemaleHeads.size()]
	else:
		newHero.headSprite = humanMaleHeads[randi() % humanMaleHeads.size()]
		
	#random class
	var randomClass = randi()%3+1 #1-4
	
	if (classStr == "Wizard"):
		newHero.heroClass = "Wizard"
		#we need better wizards, here's a twinked one:
		newHero.give_new_item("Robe of Alexandra")
		newHero.give_new_item("Scepter of the Child King")
		newHero.give_new_item("Tiny Sapphire Ring")
		newHero.give_new_item("Worn Canvas Sandals") #feet
		newHero.give_new_item("Cloth Pants") #legs
		
		
		#newHero.give_new_item("Novice's Robe") #chest
		#newHero.give_new_item("Simple Ring")
		#newHero.give_new_item("Cracked Staff")
		#newHero.give_new_item("Worn Canvas Sandals") #feet
		#newHero.give_new_item("Cloth Pants") #legs
			
	elif (classStr == "Rogue"):
		newHero.heroClass = "Rogue"
		newHero.give_new_item("Rusty Knife")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Blackguard's Chainmail Leggings")
		newHero.give_new_item("Blackguard's Chainmail Vest")

	elif (classStr == "Warrior"):
		newHero.heroClass = "Warrior"
		#twink warrior
		newHero.give_new_item("Bladestorm")
		
		#newHero.give_new_item("Rusty Broadsword")
		newHero.give_new_item("Reinforced Shield")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Worn Ringmail Leg Guards")
		newHero.give_new_item("Worn Ringmail Vest")
	
	elif (classStr == "Ranger"):
		newHero.heroClass = "Ranger"
		newHero.give_new_item("Basic Bow")
		newHero.give_new_item("Cloth Shirt")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Cloth Pants")
		
	else:
		print("ERROR - BAD HERO CLASS TYPE")

	#assign stats accordingly
	newHero.baseHp = global.heroStartingStatData[newHero.heroClass]["hp"]
	newHero.baseMana = global.heroStartingStatData[newHero.heroClass]["mana"]
	newHero.baseDps = global.heroStartingStatData[newHero.heroClass]["dps"]
	newHero.baseArmor = 0
	newHero.baseStrength = global.heroStartingStatData[newHero.heroClass]["strength"]
	newHero.baseDefense = global.heroStartingStatData[newHero.heroClass]["defense"]
	newHero.baseIntelligence = global.heroStartingStatData[newHero.heroClass]["intelligence"]
	newHero.baseSkillAlchemy = 0
	newHero.baseSkillBlacksmithing = 0
	newHero.baseSkillFletching = 0
	newHero.baseSkillJewelcraft = 0
	newHero.baseSkillTailoring = 0
	newHero.baseSkillHarvesting = 0
	newHero.baseDrama = global.heroStartingStatData[newHero.heroClass]["drama"]
	newHero.baseMood = global.heroStartingStatData[newHero.heroClass]["mood"]
	newHero.basePrestige = global.heroStartingStatData[newHero.heroClass]["prestige"]
	newHero.baseGroupBonus = global.heroStartingStatData[newHero.heroClass]["groupBonus"]
	newHero.baseRaidBonus = global.heroStartingStatData[newHero.heroClass]["raidBonus"]

	#other aspects of a hero 
	newHero.atHome = true
	newHero.level = 1
	newHero.xp = 0

	if (destinationArray == global.guildRoster):
		newHero.currentRoom = 1 #inside (0 by default - outside)
		newHero.recruited = true #false by default 
	else: #this is an unrecruited hero
		newHero.currentRoom = 0
		newHero.recruited = false
		newHero.level = randi()%3+1
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
	
	newHero.update_hero_stats() #calculate hp, mana, etc.
	newHero.hpCurrent = newHero.hp #only do this when we generate a hero (that's why it's not in update_hero_stats)
	newHero.manaCurrent = newHero.mana 
	destinationArray.append(newHero)
