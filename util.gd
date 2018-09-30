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
		
		#this is going to run this loop from 0 - n every time an item is inserted
		#this could probably be done more efficiently by keeping record of open indices somewhere else
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#finds first open null spot and puts the item there
				global.guildItems[i] = global.allGameItems[itemNameStr]
				break
	else:
		print("util.gd - ITEM NOT FOUND! ERROR! Check the spelling of: " + itemNameStr)
	
func give_item_hero(itemNameStr):
	pass