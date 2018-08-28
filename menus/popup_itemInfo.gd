extends WindowDialog
#popup_itemInfo.gd

var itemData = null
var vaultIndex = -1

signal itemDeletedOrMovedToVault

func _ready():
	if (global.currentMenu == "vault"):
		$button_moveItem.hide()
	elif (global.currentMenu == "heroPage"):
		$button_moveItem.text = "Put in vault"
	elif (global.currentMenu == "vaultViaHeroPage"):
		$button_moveItem.text = "Equip"
		
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
	
func _populate_fields():
	window_title = itemData.name
	
	#an item gives armor or dps, but not both
	if (itemData.dps > 0):
		$field_armorOrDPS.text = str(itemData.dps) + " DPS"
	elif (itemData.armor > 0):
		$field_armorOrDPS.text = str(itemData.armor) + " Armor"
	else:
		$field_armorOrDPS.hide()
		
	$sprite_itemIcon.texture = load("res://sprites/items/" + itemData.icon)
	$field_slot.text = itemData.slot.capitalize()
	
	#classes will eventually be multiples
	$field_classes.text = "Classes: " + str(itemData.classRestriction).capitalize()
	
	if (!itemData.noDrop):
		$field_noDrop.text = "Tradeable"
	else:
		$field_noDrop.text = "Binds on equip"
	
	#figure out what stats this item gives
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
	
func _on_button_trash_pressed():
	#print("trashing this item: " + itemData.name)
	emit_signal("itemDeletedOrMovedToVault")
	#todo: this might need to distinguish between whether we're on the hero page or the vault
	if (global.currentMenu == "heroPage"):
		#the current hero is available globally, so get at the item that way
		#and empty out that part of the hero's equipment object 
		if (global.selectedHero["equipment"][itemData.slot] != null):
			global.selectedHero["equipment"][itemData.slot] = null
			itemData = null
			#heroInventoryButton._clear_icon() 
			#heroInventoryButton._clear_data()
	elif (global.currentMenu == "vault"):
		#here we have to pick it out of the global equipment array 
		if (global.guildItems[vaultIndex]):
			#print("gonna delete this: " + str(global.guildItems[vaultIndex]))
			global.guildItems[vaultIndex] = null
	self.hide()

func _on_button_moveItem_pressed():
	#this button moves an item to the vault or gives it to the currently selected hero
	#depending on which menu the player came here from 
	emit_signal("itemDeletedOrMovedToVault")
	#the hero has an item in this slot: they are putting it into the vault 
	if (global.selectedHero["equipment"][itemData.slot] != null):
		#this puts the item back into the global guild item array 
		global.guildItems.append(global.selectedHero["equipment"][itemData.slot])
		#and nulls it out of the character's equipment slot 
		global.selectedHero["equipment"][itemData.slot] = null
		itemData = null
		self.hide()
	#the hero has no item in this slot: they are getting it from the vault
	elif (global.selectedHero["equipment"][itemData.slot] == null):
		#put it in the hero's equipment slot
		global.selectedHero["equipment"][itemData.slot] = global.guildItems[vaultIndex]
		global.guildItems[vaultIndex] = null #null it out of the vault, it's now on the hero
		#go back to hero page
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")  #todo: filter by item type 