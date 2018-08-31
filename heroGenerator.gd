extends Node
#makes a level 1 hero with random class and name

var nameGenerator = load("res://nameGenerator.gd").new()

func _ready():
	pass

#make new hero object
func generate(destinationArray):
	var newHero = load("res://hero.gd").new()
	newHero.heroID = global.nextHeroID
	global.nextHeroID += 1
	
	#random name
	newHero.heroName = nameGenerator.generate()
	
	#random class
	var randomNumber = randi()%3+1
	if randomNumber == 1:
		newHero.heroClass = "Wizard"
		newHero.equipment["chest"] = global.allGameItems["Novice's Robe"]
		newHero.equipment["jewelry"] = global.allGameItems["Simple Ring"]
	elif randomNumber == 2:
		newHero.heroClass = "Rogue"
		newHero.equipment["mainHand"] = global.allGameItems["Rusty Knife"]
		newHero.equipment["feet"] = global.allGameItems["Simple Chainmail Boots"]
	elif randomNumber == 3:
		newHero.heroClass = "Warrior"
		newHero.equipment["mainHand"] = global.allGameItems["Rusty Broadsword"]
		newHero.equipment["offHand"] = global.allGameItems["Reinforced Shield"]
	else:
		newHero.heroClass = "Ranger"
		newHero.equipment["mainHand"] = global.allGameItems["Basic Bow"]
		newHero.equipment["chest"] = global.allGameItems["Cloth Shirt"]

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
	else:
		newHero.currentRoom = 0
		newHero.recruited = false
		newHero.level = randi()%3+1
	
	newHero.update_hero_stats()

	destinationArray.append(newHero)
