extends Node
# mobGenerator.gd
# returns an object representing a single mob, complete with stats and loot table 

func _ready():
	pass
	
func get_mob(mobName):
	var newMob = load("res://mob.gd").new()
	newMob.mobName = mobName
	newMob.hp = staticData.mobs[mobName].hp
	newMob.mana = staticData.mobs[mobName].mana
	newMob.hpCurrent = staticData.mobs[mobName].hpCurrent
	newMob.manaCurrent = staticData.mobs[mobName].manaCurrent
	newMob.level = staticData.mobs[mobName].level
	newMob.baseResist = staticData.mobs[mobName].baseResist
	newMob.dps = staticData.mobs[mobName].dps
	newMob.strength = staticData.mobs[mobName].strength
	newMob.defense = staticData.mobs[mobName].defense
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