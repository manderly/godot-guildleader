extends Node2D

var buttonArray = []

onready var gridEquipment = $VBoxContainer/CenterContainer/TabContainer/Equipment
onready var gridTradeskillItems = $VBoxContainer/CenterContainer/TabContainer/Resources
onready var inventoryCapacity = $VBoxContainer/HBoxContainer/MarginContainer/field_guildInventoryCapacity

func _ready():
	#display inventory size and capacity
	inventoryCapacity.text = str(global.guildItems.size()) + "/" + str(global.vaultSpace)
	
	#equipment tab
	_position_vault_buttons()
	
	if (global.currentMenu == "vaultViaHeroPage"):
		global.logger(self, "Browsing for: " + global.selectedHero.heroClass + " " + str(global.browsingForSlot))
	
	#tradeskill tab
	_draw_tradeskill_items()
	
func _position_vault_buttons():
	#this method handles the STRUCTURE of the buttons
	#it places the empty buttons in the correct hboxes
	#use _draw_vault_items() to put icons and data into buttons
	
	#draw all the rows, and if there happens to be an item in the corresponding guildItems array, add its data 
	for i in range(global.vaultSpace):
		#futile attempt to get buttons to all save their indexes 
		#var itemButton = preload("res://menus/itemButton.tscn").new()
		var itemButton = preload("res://menus/itemButton.tscn").instance()
		itemButton._set_vault_index(i)
		itemButton.connect("updateSourceButtonArt", self, "_draw_vault_items")
		gridEquipment.add_child(itemButton)
		buttonArray.append(itemButton)
		
	_draw_vault_items()
	
func _draw_vault_items():
		#now we pair each physical button with data from global.guildItems array 
		#grab each button from buttonArray and "decorate" it 
		var currentButton = null
		for i in range(buttonArray.size()):
			currentButton = buttonArray[i]
			if (global.guildItems[i] && global.guildItems[i].itemType != "tradeskill"):
				currentButton._render_vault(global.guildItems[i])
				if (global.currentMenu == "vaultViaHeroPage"):
					#disable if this item isn't a slot match
					if (global.guildItems[i].slot.to_lower() != global.browsingForSlot.to_lower()):
						currentButton._set_disabled() #disable button if slot mismatch 
					
					#disable if this item isn't a class match 
					var thisHeroCanWear = false
					if (global.guildItems[i].classRestrictions[0] == "ANY"):
						thisHeroCanWear = true
					else:
						#if this isn't an "ANY" item, we have to check its restrictions against the currently selected hero
						for p in range(global.guildItems[i].classRestrictions.size()):
							if (global.guildItems[i].classRestrictions[p].to_lower() == global.selectedHero.heroClass.to_lower()):
								thisHeroCanWear = true
					if (!thisHeroCanWear):
						currentButton._set_disabled()
				elif (global.currentMenu == "blacksmithing"):
					if (global.browsingForType == "blade"):
						if (global.guildItems[i].itemType != "sword" && 
							global.guildItems[i].itemType != "knife" ||
							global.guildItems[i].improved):
							currentButton._set_disabled() #disable button if type mismatch 
			else:
				currentButton._clear_label()
				currentButton._clear_icon()
				currentButton._clear_data()
				if (global.currentMenu == "vaultViaHeroPage" || global.currentMenu == "vaultViaBlacksmith"):
					currentButton._set_disabled() #disable empty buttons but only when equipping an item onto a hero 
				#keep vault index intact 

func _draw_tradeskill_items():
	#these are on their own tab now
	print(global.tradeskillItemsSeen) #array of item names
	for i in range(global.tradeskillItemsSeen.size()):
		var tradeskillItemDisplay = preload("res://menus/crafting_ingredientDisplay.tscn").instance()
		var itemName = global.tradeskillItemsSeen[i]
		tradeskillItemDisplay._display_in_vault(global.tradeskillItemsDictionary[itemName])
		gridTradeskillItems.add_child(tradeskillItemDisplay)
	
	
func _on_button_back_pressed():
	print(global.currentMenu)
	if (global.currentMenu == "vaultViaHeroPage"):
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "vaultViaBlacksmith"):
		global.currentMenu = "blacksmithing"
		get_tree().change_scene("res://menus/crafting.tscn")
	else:
		get_tree().change_scene("res://main.tscn")
	
func _on_button_quickSort_pressed():
	#sort the array such that nulls are last 
	var start = 0
	var end = global.vaultSpace - 1
	var tmp = []
	tmp.resize(global.vaultSpace)
	
	global.logger(self, "guild items size is now:" + str(global.guildItems.size()))
	for i in range(global.vaultSpace):
		if (global.guildItems[i] != null):
			tmp[start] = global.guildItems[i]
			start += 1
		else:
			tmp[end] = global.guildItems[i]
			end -= 1
	
	for i in range(global.vaultSpace):
		global.guildItems[i] = tmp[i]
	
	_draw_vault_items()
