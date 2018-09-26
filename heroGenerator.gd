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
		
		newHero.give_item("Novice's Robe")
		newHero.give_item("Simple Ring")
		newHero.give_item("Cracked Staff")
		newHero.give_item("Worn Canvas Sandals")
		
		#sprites
		newHero.bodySprite = "body01.png"
		newHero.weapon1Sprite = "weaponMain01.png"
		newHero.weapon2Sprite = "weaponSecondary01.png"
		newHero.shieldSprite = "none.png"
		if (randomHead == 1):
			newHero.headSprite = "head01.png"
		elif (randomHead == 2):
			newHero.headSprite = "head02.png"
		else:
			newHero.headSprite = "head04.png"
			
	elif (classStr == "Rogue"):
		newHero.heroClass = "Rogue"
		
		newHero.give_item("Rusty Knife")
		newHero.give_item("Muddy Boots")
		newHero.give_item("Simple Chainmail Leggings")
		newHero.give_item("Simple Chainmail Vest")
		
		#sprites
		newHero.bodySprite = "body04.png"
		if (randomHead == 1):
			newHero.headSprite = "head01.png"
		elif (randomHead == 2):
			newHero.headSprite = "head02.png"
		else:
			newHero.headSprite = "head04.png"
		newHero.weapon1Sprite = "weaponMain03.png"
		newHero.weapon2Sprite = "weaponSecondary02.png"
		
	elif (classStr == "Warrior"):
		newHero.heroClass = "Warrior"

		newHero.give_item("Rusty Broadsword")
		newHero.give_item("Reinforced Shield")
		newHero.give_item("Muddy Boots")
		newHero.give_item("Worn Ringmail Leg Guards")
		newHero.give_item("Worn Ringmail Vest")
		
		#sprites
		newHero.bodySprite = "body03.png"
		if (randomHead == 1):
			newHero.headSprite = "head01.png"
		elif (randomHead == 2):
			newHero.headSprite = "head02.png"
		elif (randomHead == 3):
			newHero.headSprite = "head03.png"
		newHero.weapon1Sprite = "weaponMain03.png"
		newHero.shieldSprite = "shield01.png"
	
	elif (classStr == "Ranger"):
		newHero.heroClass = "Ranger"
		
		newHero.give_item("Basic Bow")
		newHero.give_item("Cloth Shirt")
		newHero.give_item("Muddy Boots")
		
		#sprites
		newHero.bodySprite = "body03.png"
		if (randomHead == 1):
			newHero.headSprite = "head01.png"
		else:
			newHero.headSprite = "head04.png"
		newHero.weapon1Sprite = "weaponMain02.png" #bow
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
	newHero.baseDrama = global.heroStartingStatData[newHero.heroClass]["drama"]
	newHero.baseMood = global.heroStartingStatData[newHero.heroClass]["mood"]
	newHero.basePrestige = global.heroStartingStatData[newHero.heroClass]["prestige"]
	newHero.baseGroupBonus = global.heroStartingStatData[newHero.heroClass]["groupBonus"]
	newHero.baseRaidBonus = global.heroStartingStatData[newHero.heroClass]["raidBonus"]

	#other aspects of a hero 
	newHero.available = true
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
