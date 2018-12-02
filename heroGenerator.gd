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
		#newHero.give_new_item("Robe of Alexandra")
		#newHero.give_new_item("Scepter of the Child King")
		#newHero.give_new_item("Tiny Sapphire Ring")
		newHero.give_new_item("Worn Canvas Sandals") #feet
		newHero.give_new_item("Cloth Pants") #legs
		newHero.give_new_item("Novice's Robe") #chest
		newHero.give_new_item("Simple Ring")
		newHero.give_new_item("Cracked Staff")
			
	elif (classStr == "Rogue"):
		newHero.heroClass = "Rogue"
		newHero.give_new_item("Rusty Knife")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Worn Ringmail Leg Guards")
		newHero.give_new_item("Worn Ringmail Vest")

	elif (classStr == "Warrior"):
		newHero.heroClass = "Warrior"
		#twink warrior
		#newHero.give_new_item("Glimmering Steel Sword")
		
		newHero.give_new_item("Rusty Broadsword")
		newHero.give_new_item("Reinforced Shield")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Worn Ringmail Leg Guards")
		newHero.give_new_item("Worn Ringmail Vest")
	
	elif (classStr == "Ranger"):
		newHero.heroClass = "Ranger"
		newHero.give_new_item("Novice's Bow")
		newHero.give_new_item("Basic Arrow")
		newHero.give_new_item("Cloth Shirt")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Cloth Pants")
		
	elif (classStr == "Cleric"):
		newHero.heroClass = "Cleric"
		#twink cleric
		#newHero.give_new_item("Sacred Mace of Tun'dn")
		#newHero.give_new_item("Shield of the Righteous")
		newHero.give_new_item("Rusty Mace")
		newHero.give_new_item("Reinforced Shield")
		newHero.give_new_item("Cloth Shirt")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Cloth Pants")

	elif (classStr == "Druid"):
		newHero.heroClass = "Druid"
		newHero.give_new_item("Cloth Shirt")
		newHero.give_new_item("Muddy Boots")
		newHero.give_new_item("Cloth Pants")		
			
	else:
		print("ERROR - BAD HERO CLASS TYPE")
		
	#random name 
	#todo: pass species in addition to gender 
	newHero.heroName = nameGenerator.generate(newHero.gender, newHero.heroClass)

	var startingStats = staticData.allHeroStartingStatData[newHero.heroClass]
	#assign stats accordingly
	newHero.baseHp = startingStats["hp"]
	newHero.baseMana = startingStats["mana"]
	newHero.baseDps = startingStats["dps"]
	newHero.baseArmor = 0
	newHero.baseStrength = startingStats["strength"]
	newHero.baseDefense = startingStats["defense"]
	newHero.baseIntelligence = startingStats["intelligence"]
	newHero.baseSkillAlchemy = 0
	newHero.baseSkillBlacksmithing = 0
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
	newHero.xp = 0

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
	
	newHero.update_hero_stats() #calculate hp, mana, etc.
	newHero.hpCurrent = newHero.hp #only do this when we generate a hero (that's why it's not in update_hero_stats)
	newHero.manaCurrent = newHero.mana
	destinationArray.append(newHero)
