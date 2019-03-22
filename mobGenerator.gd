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
	newMob.dead = false
	newMob.sprite = "res://sprites/mobs/"+staticData.mobs[mobName].sprite
	return newMob