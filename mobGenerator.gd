extends Node
# mobGenerator.gd
# returns an object representing a single mob, complete with stats and loot table 

func _ready():
	pass
	
func get_mob(mobName):
	var newMob = load("res://mob.gd").new()
	newMob.mobClass = staticData.mobs[mobName].mobClass
	
	var startingStats = staticData.heroStats[newMob.mobClass.to_lower()]
	
	newMob.mobName = mobName
	newMob.hp = startingStats["hp"]
	newMob.mana = startingStats["mana"]
	newMob.hpCurrent = startingStats["hp"]
	newMob.manaCurrent = startingStats["mana"]
	newMob.level = staticData.mobs[mobName].level
	newMob.baseResist = staticData.mobs[mobName].baseResist
	newMob.dps = staticData.mobs[mobName].dps
	newMob.strength = startingStats["strength"]
	newMob.defense = startingStats["defense"]
	newMob.dead = false
	
	if (staticData.mobs[mobName].sprite):
		newMob.sprite = staticData.mobs[mobName].sprite
	else:
		newMob.sprite = null
		
	if ("headSprite" in staticData.mobs[mobName]):
		newMob.headSprite = staticData.mobs[mobName].headSprite
	else:
		newMob.sprite = null
	
	if (staticData.mobs[mobName].loadout):
		newMob.give_gear_loadout(staticData.mobs[mobName].loadout)
		
	newMob.lootTable = staticData.mobs[mobName].lootTable
	newMob.mobID = 123
	newMob.entityType = "mob"
	return newMob