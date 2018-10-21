extends WindowDialog
#popup_itemInfo.gd
var util = load("res://util.gd").new()

var itemData = null
var vaultIndex = -1

signal itemDeletedOrMovedToVault
signal swappingItemWithAnother
signal updateStats
signal clearWildcardButton

func _ready():
	$field_stat0.hide()
	$field_stat1.hide()
	$field_stat2.hide()
	$field_stat3.hide()
	$field_stat4.hide()
	$field_stat5.hide()

func _set_vault_index(idx):
	vaultIndex = idx
	
func _set_data(data):
	itemData = data
	_populate_fields()
	_draw_buttons()
	
func _populate_fields():
	window_title = itemData.name

	$sprite_itemIcon.texture = load("res://sprites/items/" + itemData.icon)
	$field_slot.text = itemData.slot.capitalize()

	if (!itemData.noDrop):
		$field_noDrop.text = "Tradeable"
	else:
		$field_noDrop.text = "Binds on equip"
		
	if (itemData.rarity):
		$field_rarity.text = str(itemData.rarity).capitalize()
		if (itemData.rarity == "uncommon"):
			$field_rarity.add_color_override("font_color", global.colorGreen)
		elif (itemData.rarity == "rare"):
			$field_rarity.add_color_override("font_color", global.colorBlue) 
		elif (itemData.rarity == "epic"):
			$field_rarity.add_color_override("font_color", global.colorPink) 
	
	if (itemData.improved):
		$field_improved.text = "Improved " + itemData.improvement
	else:
		$field_improved.hide()
			
	print("popup_itemInfo.gd - itemID: " + str(itemData.itemID))
	if (itemData.itemID):
		$field_itemID.text = str(itemData.itemID)
		$field_itemID.add_color_override("font_color", global.colorPink) 
		
	#figure out what stats this item gives
	if (itemData.slot != "tradeskill"):
		#an item gives armor or dps, but not both
		if (itemData.dps > 0):
			$field_armorOrDPS.text = str(itemData.dps) + " DPS"
		elif (itemData.armor > 0):
			$field_armorOrDPS.text = str(itemData.armor) + " Armor"
		else:
			$field_armorOrDPS.hide()
			
		#there might be multiple class restrictions, so build a string
		var restrictionsStr = ""
		for i in range(itemData.classRestrictions.size()):
			restrictionsStr += itemData.classRestrictions[i] + " "
		#$field_classes.text = "Class: " + str(itemData.classRestriction).capitalize()
		$field_classes.text = "Classes: \n" + restrictionsStr.capitalize()
	
		var stats = []
		if (itemData.hpRaw > 0):
			stats.append("+" + str(itemData.hpRaw) + " hp")
		
		if (itemData.manaRaw > 0):
			stats.append("+" + str(itemData.manaRaw) + " mana")
		
		if (itemData.stamina > 0):
			stats.append("+" + str(itemData.stamina) + " STA")
			
		if (itemData.defense > 0):
			stats.append("+" + str(itemData.defense) + " DEF")
		
		if (itemData.intelligence > 0):
			stats.append("+" + str(itemData.intelligence) + " INT")
	
		#display them (should just be the ones greater than 0)
		for i in range(stats.size()):
			get_node("field_stat" + str(i)).text = stats[i]
			get_node("field_stat" + str(i)).show()
	else:
		$field_armorOrDPS.hide()
		$field_classes.hide()
	
func _draw_buttons():
	#must be called after data is set
	
	#we only need the trash button if we're in the vault 
	$button_trash.hide()
	
	#items we don't own (items that are previews, items that belong to unrecruited heroes, etc)
	#have a -1 ID. In this case, we can't "move" the item or trash it so hide those buttons.
	if (itemData.itemID == -1):
		$button_moveItem.hide()
		
	#the wording on the button varies with context 
	if (global.currentMenu == "vault"):
		$button_moveItem.text = "Move"
		$button_trash.show()
	elif (global.currentMenu == "heroPage"):
		$button_moveItem.text = "Put in vault"
		$button_moveItem.show()
		$button_trash.show()
	elif (global.currentMenu == "vaultViaHeroPage"):
		$button_moveItem.text = "Equip"
		$button_moveItem.show()
		$button_trash.show()
	elif (global.currentMenu == "blacksmithing" || 
			global.currentMenu == "alchemy" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "tailoring" ||
			global.currentMenu == "jewelcraft"):
		#if the wildcard slot is empty, then write "choose"
		if (!global.tradeskills[global.currentMenu].wildcardItem):
			$button_moveItem.text = "Choose"
			$button_moveItem.show()
		else:
			$button_moveItem.text = "Return to vault"
			$button_moveItem.show()
	
	#don't show move to vault or trash buttons if this hero isn't recruited
	if (global.selectedHero && !global.selectedHero.recruited):
		$button_moveItem.hide()
		
	#don't show move to vault or trash buttons if this item is on the questConfirm page
	if (global.currentMenu == "questConfirm"):
		$button_moveItem.hide()
		
func _on_button_trash_pressed():
	emit_signal("itemDeletedOrMovedToVault")
	if (global.currentMenu == "heroPage"):
		#the current hero is available globally, so get at the item that way
		#and empty out that part of the hero's equipment object 
		if (global.selectedHero["equipment"][itemData.slot] != null):
			global.selectedHero["equipment"][itemData.slot] = null
			itemData = null
			global.selectedHero.update_hero_stats()
			emit_signal("updateStats") #caught by itemButton.gd
	elif (global.currentMenu == "vault"):
		#here we have to pick it out of the global equipment array 
		if (global.guildItems[vaultIndex]):
			global.guildItems[vaultIndex] = null
	self.hide()

func _on_button_moveItem_pressed():
	if (global.currentMenu == "vault"):
		#in an item swap in the vault, this is the code for the SOURCE item 
		#it emits a signal caught by itemButton 
		#but it also makes a record of its index so vault.gd can update the button art 
		self.hide() #hide the popup
		emit_signal("swappingItemWithAnother") #caught by itemButton.gd 
	elif (global.currentMenu == "blacksmithing" || 
			global.currentMenu == "alchemy" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "tailoring" ||
			global.currentMenu == "jewelcraft"):
		if (global.tradeskills[global.currentMenu].wildcardItem):
			#we have an item, so give it back to the vault
			util.remove_item_tradeskill()
			self.hide()
			emit_signal("clearWildcardButton")
		else:
			#take the item and "give" it to the tradeskill wildcard item bucket
			util.give_item_tradeskill(itemData.itemID)
			self.hide() #hide the popup
			get_tree().change_scene("res://menus/crafting.tscn")
	else:
		#this button moves an item to the vault or gives it to the currently selected hero
		#depending on which menu the player came here from 
		emit_signal("itemDeletedOrMovedToVault") #caught by itemButton.gd 
		
		#Use case 1: player is moving this item from hero to vault
		if (global.selectedHero["equipment"][itemData.slot] != null):
			#todo: make sure the vault has room for it first 
			#todo: this method should be global because the same logic is used in questComplete.gd
			for i in range(global.guildItems.size()):
				if (global.guildItems[i] == null):
					#finds first open null spot and puts the item there
					global.guildItems[i] = global.selectedHero["equipment"][itemData.slot]
					break
			global.selectedHero["equipment"][itemData.slot] = null
			itemData = null
			global.selectedHero.update_hero_stats()
			emit_signal("updateStats") #caught by itemButton.gd
			self.hide()
			
		#Use case 2: the player is moving this item from the vault to a hero 
		elif (global.selectedHero["equipment"][itemData.slot] == null):
			#put it in the hero's equipment slot
			var vaultItem = global.guildItems[vaultIndex]
			global.selectedHero.give_existing_item(vaultItem)
			global.guildItems[vaultIndex] = null #null it out of the vault, it's now on the hero
			global.selectedHero.update_hero_stats() #recalculate hero stats
			#go back to hero page
			global.currentMenu = "heroPage"
			get_tree().change_scene("res://menus/heroPage.tscn")  #todo: filter by item type 