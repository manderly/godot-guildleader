extends WindowDialog
#popup_itemInfo.gd

var itemData = null
var vaultIndex = -1

signal itemDeletedOrMovedToVault

func _ready():
	if (global.currentMenu == "vault"):
		$button_moveItemToVault.hide()

func _set_vault_index(idx):
	vaultIndex = idx
	
func _set_data(data):
	itemData = data
	_populate_fields()
	
func _populate_fields():
	window_title = itemData.name
	$field_dps.text = "DPS: " + str(itemData.dps)
	$field_classes.text = "Classes: " + str(itemData.classRestriction)
	$field_itemStats.text = str(itemData)
	if (!itemData.noDrop):
		$field_noDrop.text = "Tradeable"
	else:
		$field_noDrop.text = "NO DROP"
	

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

func _on_button_moveItemToVault_pressed():
	#print("moving this item to the vault: " + itemData.name)
	emit_signal("itemDeletedOrMovedToVault")
	if (global.selectedHero["equipment"][itemData.slot] != null):
		#this puts the item back into the global guild item array 
		global.guildItems.append(global.selectedHero["equipment"][itemData.slot])
		#and nulls it out of the character's equipment slot 
		global.selectedHero["equipment"][itemData.slot] = null
		itemData = null
		self.hide()