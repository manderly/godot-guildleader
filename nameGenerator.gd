extends Node
const space = " "
	
const title = ["the Brave","of the Moths","the Wave Caller","the Hasty","the Idiot","the Tepid","the Careless","the Cautious","the Peacebringer","the Hazard","the Regretful","the Boring","the Sassy","the Burly","the Stalker","the Stormy","the Unwise","the Prudent","the Plaguebringer", "of the Shrubs", "of the Forest","the Firebringer","the Unwashed","the Flatulent","the Funny","the Silly","the Unbroken","the Lost"]

const guildNames = ["Faith and Fury", "Keepers of the Night", "Metal and Might", "Swords and Storms", "Magic and Mayhem", "Unconquered Legacy", "The Unbreakables", "Fires of Destiny", "Dark Destiny", "Keepers of Lore", "Old Guard Outlaws", "Midnight Empire", "The Silver Blade", "The Riverlords", "Visions of Victory", "Anomaly", "Dawn Soldiers", "Heroes of the Sword", "Mercenaries of the Coast", "High Crusaders", "Society of Nobles", "The Stonefists", "Forsaken Blades", "The Promised Ones", "Searing Force", "Stoneguard", "Guardians of the Keep", "Wisdom", "Mead and Maidens", "The Unfavored Sons", "Heirs of Fortune", "Darkbane", "The Lost Company", "Riders of the Dawn", "Truth and Honor", "The Great Dividers", "The Planeswalkers", "The Ancients", "Thunderforce", "Lightstalkers", "Unseen Order", "Chaosbringers", "Skunk Queens", "Dragonhunters", "Steel and Fury"]

static func checkIfNameInUse(newName):
	var nameIsInUse = false
	for name in global.namesInUse:
		if (newName == name):
			nameIsInUse = true
	
	return nameIsInUse
		
static func generateFirst(gender):
	
	#get a first name (gender-specific)
	var firstName = "DEFAULTFIRST"
	var firstRand = null
	
	#since this thing expects a gender, we need to make it "genderless"
	#for the random name button used in Create Hero
	#simulate it by picking a random gender each time we pick a random name 
	if (gender == "any"):
		var randomGenderNum = round(rand_range(0,1))
		if (randomGenderNum == 0):
			gender = "female"
		else:
			gender = "male"
		
	#todo: expand to take race into account (human, elf, etc)
	if (gender == "female"):
		firstRand = round(rand_range(0, names.humanFemale.size() - 1))
		firstName = names.humanFemale[firstRand]
	elif (gender == "male"):
		firstRand = round(rand_range(0, names.humanMale.size() - 1))
		firstName = names.humanMale[firstRand]

	if (checkIfNameInUse(firstName)):
		return generateFirst(gender)
	else:
		return firstName
	
static func generateLast(charClass):
	#determine if the last name is going to be class-specific or race-specific 
	var lastName = "DEFAULTLAST"
	var classLastNameRandIndex = 0
	var classSpecificLastNameRand = round(rand_range(0,100))
	if (classSpecificLastNameRand > 20): #80% chance of getting a class-specific last name
		if (charClass == "Druid" or charClass == "Ranger"):
			classLastNameRandIndex = round(rand_range(0,names.surnamesNature.size() - 1))
			lastName = names.surnamesNature[classLastNameRandIndex]
		elif (charClass == "Rogue"):
			classLastNameRandIndex = round(rand_range(0,names.surnamesRogue.size() - 1))
			lastName = names.surnamesRogue[classLastNameRandIndex]
		elif (charClass == "Warrior"):
			classLastNameRandIndex = round(rand_range(0,names.surnamesWarrior.size() - 1))
			lastName = names.surnamesWarrior[classLastNameRandIndex]
		elif (charClass == "Wizard"):
			classLastNameRandIndex = round(rand_range(0,names.surnamesWizard.size() - 1))
			lastName = names.surnamesWizard[classLastNameRandIndex]
		elif (charClass == "Cleric"):
			classLastNameRandIndex = round(rand_range(0,names.surnamesCleric.size() - 1))
			lastName = names.surnamesCleric[classLastNameRandIndex]
		else:
			#recycling nature names here for now 
			classLastNameRandIndex = round(rand_range(0,names.surnamesNature.size() - 1))
			lastName = names.surnamesNature[classLastNameRandIndex]
	else:
		#use a racial last name instead
		var lastRand = round(rand_range(0, names.surnamesHuman.size() - 1))
		lastName = names.surnamesHuman[lastRand]
		
	#rare chance at a hero being created with a title already in place
	#var titleRand = round(rand_range(0,100))
	#if (titleRand > 90):
	#	var titleRandIndex = round(rand_range(0,title.size() - 1))
	#	completeName += " " + title[titleRandIndex]
		
	return lastName
	

static func generateGuildName():
	var guildNameRand = round(rand_range(0, guildNames.size() - 1))
	#print(guildNameRand)
	var completeGuildName = guildNames[guildNameRand]
	return completeGuildName
	
func _ready():
	pass
	