extends Node
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
	
	#random name 
	#todo: pass species in addition to gender 
	newHero.heroName = nameGenerator.generate(newHero.gender)
	
	#random class
	var randomClass = randi()%3+1 #1-4
	var randomHead = randi()%3+1 #1-3
	
	if (classStr == "Wizard"):
		newHero.heroClass = "Wizard"
		#todo: must give an item to every slot or it'll crash (has no way to handle empty slots yet)
		newHero.give_item("Novice's Robe") #chest
		newHero.give_item("Simple Ring")
		newHero.give_item("Cracked Staff")
		newHero.give_item("Worn Canvas Sandals") #feet
		newHero.give_item("Cloth Pants") #legs
		newHero.shieldSprite = "none.png"
		if (randomHead == 1):
			newHero.headSprite = "human_female_01.png"
		elif (randomHead == 2):
			newHero.headSprite = "human_female_02.png"
		else:
			newHero.headSprite = "human_female_03.png"
			
	elif (classStr == "Rogue"):
		newHero.heroClass = "Rogue"
		
		newHero.give_item("Rusty Knife")
		newHero.give_item("Muddy Boots")
		newHero.give_item("Blackguard's Chainmail Leggings")
		newHero.give_item("Blackguard's Chainmail Vest")
		
		if (randomHead == 1):
			newHero.headSprite = "human_female_04.png"
		elif (randomHead == 2):
			newHero.headSprite = "human_male_01.png"
		else:
			newHero.headSprite = "human_male_05.png"
		
	elif (classStr == "Warrior"):
		newHero.heroClass = "Warrior"

		newHero.give_item("Rusty Broadsword")
		newHero.give_item("Reinforced Shield")
		newHero.give_item("Muddy Boots")
		newHero.give_item("Worn Ringmail Leg Guards")
		newHero.give_item("Worn Ringmail Vest")
		
		if (randomHead == 1):
			newHero.headSprite = "human_female_04.png"
		elif (randomHead == 2):
			newHero.headSprite = "human_male_02.png"
		elif (randomHead == 3):
			newHero.headSprite = "human_male_04.png"
		newHero.shieldSprite = "shield01.png"
	
	elif (classStr == "Ranger"):
		newHero.heroClass = "Ranger"
		
		newHero.give_item("Basic Bow")
		newHero.give_item("Cloth Shirt")
		newHero.give_item("Muddy Boots")
		newHero.give_item("Cloth Pants")
		
		if (randomHead == 1):
			newHero.headSprite = "human_female_01.png"
		else:
			newHero.headSprite = "human_male_05.png"
		newHero.weapon1Sprite = "bow1.png" #bow
		newHero.weapon2Sprite = "none.png"
	else:
		print("ERROR - BAD HERO CLASS TYPE")

	#assign stats accordingly
	newHero.baseHp = global.heroStartingStatData[newHero.heroClass]["hp"]
	newHero.baseMana = global.heroStartingStatData[newHero.heroClass]["mana"]
	newHero.baseDps = global.heroStartingStatData[newHero.heroClass]["dps"]
	newHero.baseArmor = 0
	newHero.baseStamina = global.heroStartingStatData[newHero.heroClass]["stamina"]
	newHero.baseDefense = global.heroStartingStatData[newHero.heroClass]["defense"]
	newHero.baseIntelligence = global.heroStartingStatData[newHero.heroClass]["intelligence"]
	newHero.baseSkillAlchemy = 0
	newHero.baseSkillBlacksmithing = 0
	newHero.baseSkillFletching = 0
	newHero.baseSkillJewelcraft = 0
	newHero.baseSkillTailoring = 0
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
		
		newHero.give_item("Muddy Boots") #everyone should start with shoes of some kind...

		if (gearRand1 == 1):
			newHero.give_item("Cloth Shirt")
			newHero.give_item("Worn Canvas Sandals")
		elif (gearRand1 == 2):
			newHero.give_item("Simple Ring")
		else:
			newHero.give_item("Cloth Shirt")
			newHero.give_item("Simple Ring")
	
	newHero.update_hero_stats() #calculate hp, mana, etc.
	destinationArray.append(newHero)
