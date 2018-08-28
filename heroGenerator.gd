extends Node
#makes a level 1 hero with random class and name

var nameGenerator = load("res://nameGenerator.gd").new()

func _ready():
	pass

#make new hero object
func generate(destinationArray):
	var newHero = {}
	newHero.heroID = global.nextHeroID
	global.nextHeroID += 1
	
	#random name
	newHero.heroName = nameGenerator.generate()
	
	#random class
	var randomNumber = randi()%3+1
	if randomNumber == 1:
		newHero.heroClass = "Wizard"
	elif randomNumber == 2:
		newHero.heroClass = "Rogue"
	else:
		newHero.heroClass = "Warrior"

	#assign stats accordingly
	newHero.hp = global.heroStartingStatData[newHero.heroClass]["hp"]
	newHero.mana = global.heroStartingStatData[newHero.heroClass]["mana"]
	newHero.dps = global.heroStartingStatData[newHero.heroClass]["dps"]
	newHero.stamina = global.heroStartingStatData[newHero.heroClass]["stamina"]
	newHero.defense = global.heroStartingStatData[newHero.heroClass]["defense"]
	newHero.intelligence = global.heroStartingStatData[newHero.heroClass]["intelligence"]
	newHero.drama = global.heroStartingStatData[newHero.heroClass]["drama"]
	newHero.mood = global.heroStartingStatData[newHero.heroClass]["mood"]
	newHero.prestige = global.heroStartingStatData[newHero.heroClass]["prestige"]
	newHero.groupBonus = global.heroStartingStatData[newHero.heroClass]["groupBonus"]
	newHero.raidBonus = global.heroStartingStatData[newHero.heroClass]["raidBonus"]


	#other aspects of a hero 
	newHero.available = true
	newHero.level = 1
	newHero.xp = 0
	
	#let's give this hero a sword (just for now, to see if it works)
	#todo idea: a separate script file for handling the creation/awarding/removing of items 
	newHero.equipment = {
		"mainHand": null,
		"offHand": null,
		"jewelry": null,
		"unknown": null,
		"head": null,
		"chest": null,
		"legs": null,
		"feet": null
	} 
	
	newHero.equipment["mainHand"] = global.allGameItems["Rusty Broadsword"]

	if (destinationArray == global.guildRoster):
		newHero.currentRoom = 1 #inside (0 by default - outside)
		newHero.recruited = true #false by default 
	else:
		newHero.currentRoom = 0
		newHero.recruited = false
		newHero.level = randi()%3+1

	destinationArray.append(newHero)
