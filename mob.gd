extends "baseEntity.gd"
# mob.gd

# these are properties only mobs have
var baseResist = -1
var lootTable = "batLoot01"
var mobName = "Default name"
var mobID = 123

func _ready():
	entityType = "mob"
	_hide_extended_stats()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	if (showName):
		$field_name.text = mobName
	else:
		$field_name.text = ""
	
	vignette_hide_stats()
	
func set_display_params(walkBool, nameBool):
	walkable = walkBool
	showName = nameBool
				
func _hide_extended_stats():
	$field_levelAndClass.hide()
	$field_debug.hide()
	
func set_instance_data(data):
	mobName = data.mobName
	sprite = data.sprite
	headSprite = data.headSprite
	level = data.level
	dead = data.dead
	mobID = 123 #todo: mob ID system
	hp = data.hp
	hpCurrent = data.hpCurrent
	mana = data.mana
	manaCurrent = data.manaCurrent
	baseResist = data.baseResist
	dps = data.dps
	strength = data.strength
	defense = data.strength
	lootTable = data.lootTable
	equipment = {
		"mainHand": data.equipment.mainHand,
		"offHand": data.equipment.offHand,
		"jewelry": data.equipment.jewelry,
		"unknown": null,
		"head": data.equipment.head,
		"chest": data.equipment.chest,
		"legs": data.equipment.legs,
		"feet": data.equipment.feet
	}
	#weapon1Sprite = data.weapon1Sprite
	#weapon2Sprite = data.weapon2Sprite
	#shieldSprite = data.shieldSprite
	
func get_base_resist(heroLevel):
	# mob's save roll is based on level difference between hero and mob
	#if mob > hero, mob has a greater chance to resist
	#if mob < hero, mob has a lesser chance to resist
					
	var adjustedResist = baseResist
					
	if (heroLevel > level):
		adjustedResist -= (heroLevel - level)
		if adjustedResist < 1:
			adjustedResist = 1
	elif (heroLevel < level):
		adjustedResist += (level - heroLevel)
		if adjustedResist > 19:
			adjustedResist = 19
	
	return adjustedResist

func get_melee_attack_damage():
	return dps * strength * level
	
func take_melee_damage(unmodifiedDamage):
	hpCurrent -= unmodifiedDamage
	
func take_spell_damage(dmg):
	# resists are handled in encounter generator so message can be appended to log 
	hpCurrent -= dmg
	
func say_hello():
	print(mobName + " says hello, I'm level " + str(level) + ". I have " + str(hpCurrent) + "/" + str(hp) + "hp")