extends Node
# Attach an instance to any hero, room, guild, etc. that has its own inventory
# Inventory = array 
# Vault and heroes use the inventory system to hold items they are not wearing 
# Do not confuse with equipment, which is items being "worn" by the room or hero 

var inventory = []

func _ready():
	pass # Replace with function body.

func peek_item(index):
	return inventory[index]
	
func resize(newSize):
	return inventory.resize(newSize)
	
func size():
	print(str(self) + "'s inventory size: " + str(inventory.size()))
	return inventory.size()
# the guild has 3 inventory arrays: vault, tradeskillItems, questItems
# all items in these inventories are INSTANCES OF ITEMS created using .duplicate()
# they cannot be tracked by name/ID alone because some items are modded via tradeskills

# a newly created item instance is given to the guild vault, not hero or room

# heroes have equipment
# hero.equipment = {
#   mainHand: null,
#   offHand: null,
#   jewelry: null
#   (and so on for unknown, head, chest, legs, feet)
# }

# and heroes have an inventory of X slots
# hero.inventory = []

# hero slot "unknown" is intended to hold either a food item, probably
# hero will have a bag that holds X items and can be upgraded 

# rooms have what is essentially equipment but it is called inventory to the player
# room.inventory = {
#   bed0: null,
#   bed1: null,
#   rug: null,
#   decor: null
#  }

# *** func give_new_item()
# *** params: nameStr as a string and quantity as an int
# Item must exist in staticData.items object!
# Gives a new instance of an item to the calling entity (hero or vault, typically)
# ex: vault.give_new_item("Fluff", 5)
# ex: hero.give_new_item("Bat Wing", 1) 
func give_new_item(nameStr, quantity):
	print("[Inventory Class] Creating " + str(quantity) + " new " + nameStr + " and giving it to " + str(self))
	
	if (staticData.items.has(nameStr)):
		# find a place for it
		for i in range(inventory.size()):
			if (inventory[i] == null):
				# finds the first null spot and creates the new item there 
				inventory[i] = staticData.items[nameStr].duplicate()
				inventory[i].itemID = global.nextItemID
				global.nextItemID += 1
				break
	else:
		print("Could not create item [" + nameStr + "]! Item does not exist in staticData.items.")

# *** func take_item()
# *** params: itemID
# Gives a new instance of an item to the calling entity (hero or vault, typically)
# ex: var item = vault.take_item(123)
# ex: hero.give_item(item)
func take_item(itemID):
	print("Taking item with ID " + str(itemID) + " from " + str(self))
	# take item from this entity (hero, bedroom) and give it back to the guild vault
	# ex: hero.return_item_to_vault(123)
	# ex: bedroom.return_item_to_vault(123)
	# takes item ID 123 from hero and places it in guild vault array 
	pass
	
# *** func give_item()
# *** params: actual item instance
# Gives an EXISTING item instance to this inventory
# Used for giving modded items to vault, items to hero inventories 
# ex: global.vault.give_item(moddedItem) 
func give_item(item):
	print("Giving item [" + str(item.name) + " to " + str(self))
	
	for i in range(inventory.size()):
		if (inventory[i] == null):
			inventory[i] = item
		if (i == inventory.size()):
			print("inventory.gd: Could not find room for this item!")
	
# *** func trash_item()
# *** params: actual item instance
# Delete this EXISTING ITEM from an array-type inventory 
func trash_item(item):
	# deletes this specific item instance from the game. Does not free its ID. 
	print("Trashing item with ID " + str(item.name))
