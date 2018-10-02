extends Node

func _ready():
	pass

#use: util.format_time(timeData) 
func format_time(time):
	var timeFormattedForDisplay = null
	if (time > 3599):
		timeFormattedForDisplay = str(round(time / 3600)) + "h"
	elif (time > 59):
		timeFormattedForDisplay = str(round(time / 60)) + "m"
	else:
		timeFormattedForDisplay = str(round(time)) + "s"
		
	return timeFormattedForDisplay
	
func give_item_guild(itemNameStr):
	if (global.allGameItems[itemNameStr]): #make sure this item actually exists in the item records
		#naive solution: doing this just sticks the new item at the very end of all the empty slots
		#global.guildItems.append(global.allGameItems[itemNameStr])
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[itemNameStr]
				break
	else:
		print("util.gd - ITEM NOT FOUND! ERROR! Check the spelling of: " + itemNameStr)
	
func give_item_hero(itemNameStr):
	pass
	
func give_item_blacksmith(itemNameStr):
	if (global.allGameItems[itemNameStr]): #make sure this item actually exists
		global.blacksmithingWildcardItem = global.allGameItems[itemNameStr]
	#todo: flag it somehow to the user (don't remove it from guild) 
	
func remove_item_blacksmith():
	global.blacksmithingWildcardItem = null
	