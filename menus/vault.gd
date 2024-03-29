extends Node2D

var buttonArray = []

onready var gridEquipment = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Equipment/CenterContainer/Grid
onready var gridTradeskillItems = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Resources
onready var gridQuestItems = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Quest_Items
onready var inventoryCapacity = $CenterContainer/VBoxContainer/HBoxContainer/MarginContainer/field_guildInventoryCapacity

onready var tabContainer = $CenterContainer/VBoxContainer/CenterContainer/TabContainer

func _ready():
	# workaround for underscore in "Quest_Items" and eventual translation support
	var tabTitles = ["Equipment", "Quest Items", "Crafting"]
	for i in range(tabContainer.get_tab_count()):
		tabContainer.set_tab_title(i, tabTitles[i])
		
	#display inventory size and capacity
	inventoryCapacity.text = str(global.vault.size()) + "/" + str(global.vaultSpace)
	
	#equipment tab
	_position_vault_buttons()
	
	if (global.currentMenu == "vaultViaHeroPage"):
		global.logger(self, "Browsing for: " + global.selectedHero.charClass + " " + str(global.browsingForSlot))
	
	#tradeskill tab and quest tab
	_draw_tradeskill_items()
	_draw_quest_items()
	
func _position_vault_buttons():
	#this method handles the STRUCTURE of the buttons
	#it places the empty buttons in the correct hboxes
	#use _draw_vault_items() to put icons and data into buttons
	
	#draw all the rows, and if there happens to be an item in the corresponding guildItems array, add its data 
	for i in range(global.vaultSpace):
		var itemButton = preload("res://menus/itemButton.tscn").instance()
		itemButton._set_vault_index(i)
		itemButton.connect("updateSourceButtonArt", self, "_draw_vault_items")
		gridEquipment.add_child(itemButton)
		buttonArray.append(itemButton)
		if (global.currentMenu == "vaultViaHeroPage"):
			itemButton._set_info_popup_buttons(true, true, "Equip")
		elif (global.currentMenu == "vaultViaBedroomPage"):
			itemButton._set_info_popup_buttons(true, true, "Place")
		elif (global.currentMenu == "alchemy" ||
			global.currentMenu == "blacksmithing" ||
			global.currentMenu == "chronomancy" ||
			global.currentMenu == "jewelcraft" ||
			global.currentMenu == "tailoring" ||
			global.currentMenu == "woodcraft"):
			#must have come from a crafting page
			itemButton._set_info_popup_buttons(true, true, "Select")
		else:
			itemButton._set_info_popup_buttons(true, true, "Move")
	_draw_vault_items()
	
func _draw_vault_items():
		#now we pair each physical button with data from global.guildItems array 
		#grab each button from buttonArray and "decorate" it 
		var currentButton = null
		for i in range(buttonArray.size()):
			currentButton = buttonArray[i]
			
			var item = global.vault.peek_item(i)
			if (item):
				#normal item 
				currentButton._render_vault(item)
				if (global.currentMenu == "vaultViaHeroPage"):
					#disable if this item isn't a slot match
					if (item.slot.to_lower() != global.browsingForSlot.to_lower()):
						currentButton.set_disabled(true) #disable button if slot mismatch 
					
					#check class restrictions 
					var thisHeroCanWear = false
					if (item.classRestrictions[0] == "any"):
						thisHeroCanWear = true
					else:
						#if this isn't an "ANY" item, we have to check its restrictions against the currently selected hero
						for p in range(item.classRestrictions.size()):
							if (item.classRestrictions[p] != null):
								if (item.classRestrictions[p].to_lower() == global.selectedHero.charClass.to_lower()):
									thisHeroCanWear = true
					# disable button if item outside of class restriction 
					if (!thisHeroCanWear):
						currentButton.set_disabled(true)
						
				elif (global.currentMenu == "vaultViaBedroomPage"):
					#disable if this item isn't a slot match
					if (item.slot.to_lower() != global.browsingForSlot.to_lower()):
						currentButton.set_disabled(true) #disable button if slot mismatch 
				elif (global.currentMenu == "blacksmithing"):
					if (global.browsingForType == "blade"):
						if (item.itemType != "sword" && 
							item.itemType != "knife" ||
							item.improved):
							currentButton.set_disabled(true) #disable button if type mismatch 
				elif (global.currentMenu == "tailoring"):
					if (global.browsingForType == "cloth"):
						if (item.material != "cloth"):
							currentButton.set_disabled(true) #disable button if type mismatch 
			else:
				currentButton._clear_label()
				currentButton._clear_icon()
				currentButton._clear_data()
				if (global.currentMenu == "vaultViaHeroPage" || 
					global.currentMenu == "vaultViaBlacksmith" ||
					global.currentMenu == "vaultViaBedroomPage"):
					currentButton.set_disabled(true) #disable empty buttons but only when equipping an item onto a hero 
				#keep vault index intact 

func _draw_tradeskill_items():
	#these are on their own tab
	#print(global.tradeskillItemsSeen) #array of item names
	for i in range(global.tradeskillItemsSeen.size()):
		var tradeskillItemDisplay = preload("res://menus/smallItemDisplay.tscn").instance()
		var itemName = global.tradeskillItemsSeen[i]
		tradeskillItemDisplay._display_in_vault(global.playerTradeskillItems[itemName])
		gridTradeskillItems.add_child(tradeskillItemDisplay)

func _draw_quest_items():
	#these are on their own tab
	#print(global.questItemsSeen) #array of item names
	for item in global.questItemsSeen:
		var questItemDisplay = preload("res://menus/smallItemDisplay.tscn").instance()
		var itemName = item
		questItemDisplay._display_in_vault(global.playerQuestItems[itemName])
		gridQuestItems.add_child(questItemDisplay)
	
	
func _on_button_back_pressed():
	#print(global.currentMenu)
	if (global.currentMenu == "vaultViaHeroPage"):
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "vaultViaBlacksmith"):
		global.currentMenu = "blacksmithing"
		get_tree().change_scene("res://menus/crafting.tscn")
	elif (global.currentMenu == "vaultViaBedroomPage"):
		global.currentMenu = "bedroomPage"
		get_tree().change_scene("res://menus/bedroomPage.tscn")
	else:
		get_tree().change_scene("res://main.tscn")
	
func _on_button_quickSort_pressed():
	#sort the array such that nulls are last 
	global.vault.quick_sort()
	_draw_vault_items()
