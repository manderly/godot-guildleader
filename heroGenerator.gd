extends Node
#makes a level 1 hero with random class and name

var nameGenerator = load("res://nameGenerator.gd").new()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#make new hero object
func generate(destinationArray):
	var newHero = {}
	
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

	newHero.level = 1
	newHero.xp = 0
	if (destinationArray == global.guildRoster):
		newHero.currentRoom = 1 #inside (0 by default - outside)
		newHero.recruited = true #false by default 
	else:
		newHero.currentRoom = 0
		newHero.recruited = false
		newHero.level = randi()%3+1
		
	newHero.available = true

	destinationArray.append(newHero)
