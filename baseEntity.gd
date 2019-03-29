extends KinematicBody2D

# Both mobs and heroes can take a humanoid appearance, so here's all the possible heads
var humanFemaleHeads = ["human_female_01.png", "human_female_02.png", "human_female_03.png", "human_female_04.png", "human_female_05.png", "human_female_06.png", "human_female_07.png", "human_female_08.png", "human_female_09.png", "human_female_10.png", "human_female_11.png"]
var humanMaleHeads = ["human_male_01.png", "human_male_02.png", "human_male_03.png", "human_male_04.png", "human_male_05.png", "human_male_06.png", "human_male_07.png", "human_male_08.png", "human_male_08.png", "human_male_09.png"]
var elfFemaleHeads = ["elf_female_01.png"]

# everyone's a bat until proven otherwise
var sprite = null #"res://sprites/mobs/bat/bat_01.png"

# Entity properties
# Heroes: These are set when a hero is randomly generated in heroGenerator.gd 
# Mobs: These are set when a mob is randomly generated using spreadsheet data 

var level = -1
var archetype = "NONE"
var dead = false
var entityType = "tbd"
var charClass = null

#for distinguishing "walkers" (main scene) from usages of the hero not walking (hero page, buttons, etc) 
var walkable = false
var showName = true

var battlePrint = false

#Hero base stats come from external spreadsheet data
#These are first set when a hero is randomly generated in heroGenerator.gd

#BASE STATS - bulldoze these -1's with data that comes in from heroData.json data (heroGenerator.gd) 
var baseHp = -1
var baseMana = -1
var baseArmor = -1
var baseDps = -1
var baseStrength = -1
var baseDefense = -1
var baseIntelligence = -1
var baseSkillAlchemy = -1
var baseSkillBlacksmithing = -1
var baseSkillChronomancy = -1
var baseSkillFletching = -1
var baseSkillJewelcraft = -1
var baseSkillTailoring = -1
var baseSkillHarvesting = -1
var baseDrama = 0
var baseMood = 0
var basePrestige = -1
var baseGroupBonus = "none"
var baseRaidBonus = "none"

var baseRegenRateHP = 1
var baseRegenRateMana = 1
	
var classLevelModifiers = {
	"Warrior":{
		"hp":1.26,
		"mana":1,
		"strength":1.2,
		"defense":1.08
		},
	"Rogue":{
		"hp":1.24,
		"mana":1,
		"strength":1.2,
		"defense":1.02
		},
	"Ranger":{
		"hp":1.25,
		"mana":1,
		"strength":1.2,
		"defense":1.03
		},
	"Wizard":{
		"hp":1.21,
		"mana":1.28,
		"strength":1,
		"defense":1.00
		},
	"Cleric":{
		"hp":1.25,
		"mana":1.28,
		"strength":1,
		"defense":1.07
		},
	"Druid":{
		"hp":1.22,
		"mana":1.27,
		"strength":1,
		"defense":1.05
		},
}

#EQUIPMENT MODIFIED STATS - the total from the hero's worn items (equipment dictionary further down)
var modifiedHp = 0
var modifiedMana = 0
var modifiedArmor = 0
var modifiedDps = 0
var modifiedStrength = 0
var modifiedDefense = 0
var modifiedIntelligence = 0
var modifiedSkillAlchemy = 0
var modifiedSkillBlacksmithing = 0
var modifiedSkillChronomancy = 0
var modifiedSkillFletching = 0
var modifiedSkillJewelcraft = 0
var modifiedSkillTailoring = 0
var modifiedSkillHarvesting = 0
var modifiedPrestige = 0

var modifiedRegenRateHP = 0
var modifiedRegenRateMana = 0

#TODO: Buffs - someday, buffs will affect stats, too. 

#FINAL STATS - combine base and modified stats. For now, default to -1 until the math is done.  
var hpCurrent = -1
var hp = -1
var manaCurrent = -1
var mana = -1
var armor = -1
var dps = -1
var strength = -1
var defense = -1
var intelligence = -1
var skillAlchemy = -1
var skillBlacksmithing = -1
var skillChronomancy = -1
var skillFletching = -1
var skillJewelcraft = -1
var skillTailoring = -1
var skillHarvesting = -1
var drama = 0
var mood = 0
var prestige = -1
var groupBonus = "none"
var raidBonus = "none"

var regenRateHP = -1
var regenRateMana = -1

#This hero's items (equipment)
#to access: heroInstance.equipment.mainHand
var equipment = {
	"mainHand": null,
	"offHand": null,
	"jewelry": null,
	"unknown": null,
	"head": null,
	"chest": null,
	"legs": null,
	"feet": null
} 

#Body sprite names (todo: should eventually take sprite data from equipment dictionary)
var headSprite = "head01.png"
var chestSprite = "body01.png"
var weapon1Sprite = "weapon01.png"
var weapon2Sprite = "none.png"
var shieldSprite = "none.png"
var legsSprite = "pants04.png"
var bootSprite = "boots04.png"

func clear_all_items():
	equipment = {
		"mainHand": null,
		"offHand": null,
		"jewelry": null,
		"unknown": null,
		"head": null,
		"chest": null,
		"legs": null,
		"feet": null
	}
	
func get_class_role():
	#returns string dps, tank, healer
	var role = ""
	if (charClass == "Wizard" || charClass == "Ranger" || charClass == "Rogue" || charClass == "Monk"):
		role = "dps"
	elif (charClass == "Paladin" || charClass == "Warrior"):
		role = "tank"
	elif (charClass == "Cleric" || charClass == "Druid"):
		role = "support"
	else:
		role = "ERROR"
	return role

	
func get_is_caster_type():
	#returns boolean, true = has mana, false = no mana
	var isCaster = false
	if (charClass == "Wizard" || charClass == "Paladin" || charClass == "Cleric" || charClass == "Druid" || charClass == "Necromancer"):
		isCaster = true
	return isCaster

func get_melee_attack_damage():
	return round((dps * (strength + (level * dps))) / level)
	
func melee_attack():
	# battlePrint = true
	var rawDmg = (equipment["mainHand"].dps * strength) / 2
	var roll = randi()%20+1 #(roll between 1-20)
	if (roll == 1):
		if (battlePrint):
			print("miss!")
		rawDmg = 0
	elif (roll == 20):
		if (battlePrint):
			print("Critical hit! Double damage!")
		rawDmg *= 2
	if (battlePrint):
		print("Returning this raw damage: " + str(rawDmg))
	return rawDmg

func get_healed(amount):
	hpCurrent += amount
	if (hpCurrent > hp):
		hpCurrent = hp #cannot exceed max 

func _get_rand_between(firstVal, secondVal):
	var bottom = firstVal
	var top = secondVal
	
	if (secondVal < firstVal): #figure out which value is lower (ie: if we pass (8,0) we can't use them as-is) 
		bottom = secondVal
		top = firstVal
	
	var randNum = randi()%int(top)+int(bottom) #1-100, 5-10, 600-1900, etc
	return randNum

func calculate_melee_damage_mitigated(unmodifiedDamage, attackerLevel):
	#print("using this defense score as the miss bar: " + str(defense))
	# calculate mitigation 
	var modifiedDamage = unmodifiedDamage
	# first, see if the attacker missed
	# attacker has greater chance of missing the lower his level in relation to mine
	var missBar = defense #the "bar" for missing uses the defense score to start
	if (level > attackerLevel):
		# I'm higher level, raise the 'miss bar' by the difference between our levels and make it less likely that an attack hits me
		missBar += (level - attackerLevel) * 2
		if (missBar > 97):
			missBar = 98
	elif (attackerLevel >= level):
		# Attacker is higher level or same as me, lower the miss bar and make it more likely that an attack hits me
		missBar -= (attackerLevel - level) * attackerLevel
		if (missBar < 0):
			missBar = 0
	
	# now the "missBar" is somewhere between 0 and 100
	# for this attack to miss, we have to roll a number higher than the miss bar
	var missRand = _get_rand_between(0, 100)
	if (missRand > missBar):
		#attack hits
		# defense determines how much damage is actually done
		modifiedDamage = round(unmodifiedDamage * unmodifiedDamage / (unmodifiedDamage + defense))
		if (level > attackerLevel):
			# reduce damage a bit more if I'm higher level than my attacker
			# the bigger the level gap, the more that the attack is reduced by
			modifiedDamage -= round(level - attackerLevel / 2)
			if (modifiedDamage < 0):
				modifiedDamage = 1
		#print("Level " + str(attackerLevel) + " attacks level " + str(level) + " for " + str(modifiedDamage) + " dmg (unmodified: " + str(unmodifiedDamage) + ")")
	else:
		
		# attack misses entirely
		#print("Level " + str(attackerLevel) + " tried to attack level " + str(level) + " but missed!")
		modifiedDamage = 0
		
	return modifiedDamage
	
func take_melee_damage(damage):
	hpCurrent -= damage
	
#this method generates a brand new instance of the item, it's an equivalent
#to the method used in util.gd to give new items to the guild
func give_new_item(itemNameStr): 
	#To use: hero.give_item("Item Name Here")
	#hero.give_item("item name here", false) #for items from the vault 
	var newItem = staticData.items[itemNameStr].duplicate() #make a new instance from the big book of items
	newItem.itemID = global.nextItemID
	global.nextItemID += 1
	equipment[newItem.slot] = newItem #now give it to the matching equipment slot on this hero

func give_gear_loadout(loadoutIDStr):
	clear_all_items()
	#get the loadout from staticData
	var loadout = staticData.loadouts[loadoutIDStr]
	#iterate through object and give each item to the hero
	for key in loadout.keys():
		if (key == "loadoutId" || key == "unknown"): 
			continue #don't process entries that aren't actually items
		elif (loadout[key]): #skip empty spots
			give_new_item(loadout[key])

func vignette_hide_stats():
	$field_HP.hide()
	$label_hp.hide()
	$field_Mana.hide()
	$label_mana.hide()

func vignette_die():
	$body.modulate = Color(0.8, 0.7, 1)
	#todo: animate the change

func vignette_show_stats():
	$field_HP.show()
	$label_hp.show()

	if get_is_caster_type():
		$field_Mana.show()
		$label_mana.show()

	$field_levelAndClass.hide()

func _draw_sprites():
	# this method is for both heroes and mobs
	# a hero always has all the usual body parts (head, feet, weapons, etc)
	# but a mob can be humanoid or a singular "oneBody" sprite

	var none = "res://sprites/heroes/none.png"

	#if not a oneBody, then it's a humanoid with a visible gear loadout 
	if (!sprite):
		#everyone has a head, no need to else/if this one 
		$body/head.texture = load("res://sprites/heroes/head/" + headSprite)

		# heroes can walk around empty-handed, so check that gear actually exists 
		# or just hide the slot 
		if (equipment.mainHand):
			$body/weapon1.texture = load("res://sprites/heroes/weaponMain/" + equipment.mainHand.bodySprite)
		else:
			$body/weapon1.hide() #texture = load(none)
		
		#shields are offhand items but they use a different node on the hero body 
		if (equipment.offHand):
			if (equipment.offHand.itemType == "shield"):
				$body/shield.texture = load("res://sprites/heroes/offHand/" + equipment.offHand.bodySprite)
				$body/weapon2.hide() #texture = load(none)
			else:
				$body/weapon2.texture = load("res://sprites/heroes/offHand/" + equipment.offHand.bodySprite)
				$body/shield.hide() #texture = load(none)
		else:
			$body/weapon2.hide() #texture = load(none)
			$body/shield.hide() #texture = load(none)

		# these have a "missing.png" to display if there's no texture or no item equipped
		# this is the current solution to "naked" characters and the bright pink
		# missing.png helps identify items with missing sprites
		if (equipment.chest):
			$body/chest.texture = load("res://sprites/heroes/chest/" + equipment.chest.bodySprite)
		else:
			$body/chest.texture = load("res://sprites/heroes/chest/missing.png")
		
		if (equipment.legs):
			$body/legs.texture = load("res://sprites/heroes/legs/" + equipment.legs.bodySprite)
		else:
			$body/legs.texture = load("res://sprites/heroes/legs/missing.png")
		
		if (equipment.feet):
			$body/boot1.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
			$body/boot2.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
		else:
			$body/boot1.texture = load("res://sprites/heroes/feet/missing.png")
			$body/boot2.texture = load("res://sprites/heroes/feet/missing.png")
	elif (sprite):
		#otherwise, it's a oneBody
		# oneBody are usually mobs but could be used later for special forms heroes take
		# ie: a druid in a wolf form
		# sprite is a var on baseEntity but it's set (maybe) in _ready
		$body/oneSprite.texture = load("res://sprites/mobs/" + sprite)
		$body/oneSprite.show()
		$body/weapon1.hide() 
		$body/weapon2.hide()
		$body/shield.hide()
		$body/head.hide()
		$body/chest.hide()
		$body/legs.hide()
		$body/boot1.hide()
		$body/boot2.hide()