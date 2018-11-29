extends Node
# mobGenerator.gd
# returns an object representing a single mob, complete with stats and loot table 

func _ready():
	pass
	
func get_mob(mobName):
	return staticData.allMobData[mobName]