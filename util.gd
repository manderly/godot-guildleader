extends Node
#util.gd 

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
	
func give_item_guild(itemName): #itemName comes in as a string 
	if (global.allGameItems[itemName]): #make sure this item actually exists in the item records
		#finds first open null spot and puts the item there
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				global.guildItems[i] = global.allGameItems[itemName]
				break
	else:
		print("util.gd - ITEM NOT FOUND! ERROR! Check the spelling of: " + itemName)

func give_modded_item_guild(itemName, stat, bonusAmount): #itemName comes in as a string 
	print("giving a modded item to the guild")
	if (global.allGameItems[itemName]): #make sure this item actually exists in the item records
		#finds first open null spot and puts the item there
		for i in range(global.guildItems.size()):
			if (global.guildItems[i] == null):
				#todo: modifies ALL instances of this weapon for some reason 
				global.guildItems[i] = global.allGameItems[itemName].duplicate()
				#now apply the mods
				global.guildItems[i][stat] += bonusAmount
				break
	else:
		print("util.gd - ITEM NOT FOUND! ERROR! Check the spelling of: " + itemName)
		
					
func remove_item_guild(itemNameStr):
	print("util.gd: Removing " + itemNameStr + " from guild's inventory")
	if (global.allGameItems[itemNameStr]): #make sure this item actually exists in the item records
		#find the item (loop through all items)
		#delete it by nulling its index 
		for i in range(global.guildItems.size()):
			if (global.guildItems[i]): #if we don't null check it'll crash on trying to get .name 
				if (global.guildItems[i].name == itemNameStr):
					global.guildItems[i] = null
					break
	else:
		print("util.gd - ITEM NOT FOUND! ERROR! Check the spelling of: " + itemNameStr)
		
func give_item_hero(itemNameStr):
	pass
	
func give_item_tradeskill(itemNameStr):
	if (global.allGameItems[itemNameStr]): #make sure this item actually exists
		global.tradeskills[global.currentMenu].wildcardItem = global.allGameItems[itemNameStr]
	
func remove_item_tradeskill():
	global.tradeskills[global.currentMenu].wildcardItem = null
	