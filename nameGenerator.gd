extends Node
const space = " "
	
const title = ["the Brave","of the Moths","the Wave Caller","the Hasty","the Idiot","the Tepid","the Careless","the Cautious","the Peacebringer","the Hazard","the Regretful","the Boring","the Sassy","the Burly","the Stalker","the Stormy","the Unwise","the Prudent","the Plaguebringer", "of the Shrubs", "of the Forest","the Firebringer","the Unwashed","the Flatulent","the Funny","the Silly","the Unbroken","the Lost"]

const guildNames = ["Faith and Fury", "Keepers of the Night", "Metal and Might", "Swords and Storms", "Magic and Mayhem", "Unconquered Legacy", "The Unbreakables", "Fires of Destiny", "Dark Destiny", "Keepers of Lore", "Old Guard Outlaws", "Midnight Empire", "The Silver Blade", "The Riverlords", "Visions of Victory", "Anomaly", "Dawn Soldiers", "Heroes of the Sword", "Mercenaries of the Coast", "High Crusaders", "Society of Nobles", "The Stonefists", "Forsaken Blades", "The Promised Ones", "Searing Force", "Stoneguard", "Guardians of the Keep", "Wisdom", "Mead and Maidens", "The Unfavored Sons", "Heirs of Fortune", "Darkbane", "The Lost Company", "Riders of the Dawn", "Truth and Honor", "The Great Dividers", "The Planeswalkers", "The Ancients", "Thunderforce", "Lightstalkers", "Unseen Order", "Chaosbringers", "Skunk Queens", "Dragonhunters", "Steel and Fury"]

static func generate(gender, heroClass):
	
	#get a first name (gender-specific)
	var firstName = "DEFAULTFIRST"
	var firstRand = null
	#todo: expand to take race into account (human, elf, etc)
	if (gender == "female"):
		firstRand = round(rand_range(0, staticData.humanFemaleNames.size() - 1))
		firstName = staticData.humanFemaleNames[firstRand]
	elif (gender == "male"):
		firstRand = round(rand_range(0, staticData.humanFemaleNames.size() - 1))
		firstName = staticData.humanMaleNames[firstRand]
	
	#now, determine if the last name is going to be class-specific or race-specific 
	var lastName = "DEFAULTLAST"
	var classLastNameRandIndex = 0
	var classSpecificLastNameRand = round(rand_range(0,100))
	if (classSpecificLastNameRand > 20): #80% chance of getting a class-specific last name
		if (heroClass == "Druid" or heroClass == "Ranger"):
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesNature.size() - 1))
			lastName = staticData.surnamesNature[classLastNameRandIndex]
		elif (heroClass == "Rogue"):
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesRogue.size() - 1))
			lastName = staticData.surnamesRogue[classLastNameRandIndex]
		elif (heroClass == "Warrior"):
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesWarrior.size() - 1))
			lastName = staticData.surnamesWarrior[classLastNameRandIndex]
		elif (heroClass == "Wizard"):
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesWizard.size() - 1))
			lastName = staticData.surnamesWizard[classLastNameRandIndex]
		elif (heroClass == "Cleric"):
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesCleric.size() - 1))
			lastName = staticData.surnamesCleric[classLastNameRandIndex]
		else:
			#recycling nature names here for now 
			classLastNameRandIndex = round(rand_range(0,staticData.surnamesNature.size() - 1))
			lastName = staticData.surnamesNature[classLastNameRandIndex]
	else:
		#use a racial last name instead
		var lastRand = round(rand_range(0, staticData.surnamesHuman.size() - 1))
		lastName = staticData.surnamesHuman[lastRand]
	
	var completeName = firstName + space + lastName
	
	#rare chance at a hero being created with a title already in place
	var titleRand = round(rand_range(0,100))
	if (titleRand > 90):
		var titleRandIndex = round(rand_range(0,title.size() - 1))
		completeName += " " + title[titleRandIndex]
		
	return completeName

static func generateGuildName():
	var guildNameRand = round(rand_range(0, guildNames.size() - 1))
	print(guildNameRand)
	var completeGuildName = guildNames[guildNameRand]
	return completeGuildName
	
func _ready():
	pass
	