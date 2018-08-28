extends WindowDialog
#popup_itemInfo.gd

var itemData = null

func _ready():
	pass
	
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
	#todo: this might need to distinguish between whether we're on the hero page or the vault
	print("trashing this item: " + itemData.slot)
	#for now, assume we are on the hero page
	#the current hero is available globally, so get at the item that way
	#and empty out that part of the hero's equipment object 
	if (global.selectedHero["equipment"][itemData.slot] != null):
		global.selectedHero["equipment"][itemData.slot] = null
		itemData = null
		self.hide()
		#heroInventoryButton._clear_icon() 
		#heroInventoryButton._clear_data()


func _on_button_moveItemToVault_pressed():
	print("moving this item to the vault: " + itemData.name)
	if (global.selectedHero["equipment"][itemData.slot] != null):
		#this puts the item back into the global guild item array 
		global.guildItems.append(global.selectedHero["equipment"][itemData.slot])
		#and nulls it out of the character's equipment slot 
		global.selectedHero["equipment"][itemData.slot] = null
		itemData = null
		self.hide()