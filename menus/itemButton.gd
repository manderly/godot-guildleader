extends Button

onready var itemPopup = preload("res://menus/popup_itemInfo.tscn").instance()
var itemData = null
var itemVaultIndex = -1 #only needed when this button is used on the vault page 
signal updateSourceButtonArt

func _ready():
	#todo: use some math to center it
	itemPopup.connect("itemDeletedOrMovedToVault", self, "deletedOrRemoved_callback")
	itemPopup.connect("swappingItemWithAnother", self, "swapState_callback")
	add_child(itemPopup)
	
func deletedOrRemoved_callback():
	if (global.currentMenu == "vault"):
		_clear_label()
	_clear_data()
	_clear_icon()
	
func swapState_callback():
	global.inSwapItemState = true
	#must save this index globally, individual buttons don't know the "source" index otherwise 
	#this global var will be used again in vault.gd to update the source button's art 
	global.swapItemSourceIdx = itemVaultIndex
	
func _set_vault_index(idx):
	itemVaultIndex = idx

func _set_label(inventorySlotName):
	$field_slotName.text = inventorySlotName

func _clear_label():
	$field_slotName.text = ""
	
func _set_icon(filename):
	$sprite_itemIcon.texture = load("res://sprites/items/" + filename)

func _clear_icon():
	$sprite_itemIcon.texture = null
	
func _set_data(data):
	itemData = data
	
func _clear_data():
	itemData = null
	itemVaultIndex = -1

func _on_Button_pressed():
	if (global.inSwapItemState):
		#we are clicking on the destination button (the source button set global.inSwapItemState)
		var destinationItem = global.guildItems[itemVaultIndex]
		var sourceItem = global.guildItems[global.swapItemSourceIdx]
		#perform the swap 
		global.guildItems[itemVaultIndex] = sourceItem
		global.guildItems[global.swapItemSourceIdx] = destinationItem
		#update this button's data and icon
		_set_data(global.guildItems[itemVaultIndex])
		_set_icon(global.guildItems[itemVaultIndex].icon)
		_set_label(global.guildItems[itemVaultIndex].slot)
		global.inSwapItemState = false
		#updating the source button's icon/label/etc has to be handled by the Vault parent,
		#since this button (the destination at this point) has no idea what button that was
		emit_signal("updateSourceButtonArt")
	else:
		#save a record of the previous button clicked for use in swapping items 
		global.lastItemButtonClicked = self
		print(global.lastItemButtonClicked)
		#only show the item popup if there is an item, otherwise go to the vault
		if (itemData):
			itemPopup._set_data(itemData)
			itemPopup._set_vault_index(itemVaultIndex)
			itemPopup.popup()
		else:
			if (global.currentMenu == "heroPage"):
				global.currentMenu = "vaultViaHeroPage"
				get_tree().change_scene("res://menus/vault.tscn")  #todo: filter by item type 
