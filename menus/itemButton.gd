extends Control

onready var itemPopup = preload("res://menus/popup_itemInfo.tscn").instance()
var itemData = null
var itemVaultIndex = -1 #only needed when this button is used on the vault page 
var itemSlot = null #used on heroPage to know what to filter by

signal updateSourceButtonArt
signal updateStatsOnHeroPage

func _ready():
	#todo: use some math to center it
	itemPopup.connect("itemDeletedOrMovedToVault", self, "deletedOrRemoved_callback")
	itemPopup.connect("swappingItemWithAnother", self, "swapState_callback")
	itemPopup.connect("updateStats", self, "updateStats_callback") #middleman to pass signal up to heroPage.gd
	itemPopup.connect("clearWildcardButton", self, "_clear_tradeskill")
	add_child(itemPopup)
	
func updateStats_callback():
	emit_signal("updateStatsOnHeroPage")
	
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
	#display it in the corner for now 
	$Button/field_vaultIdx.text = str(itemVaultIndex)

func _set_label(inventorySlotName):
	$Button/field_slotName.text = inventorySlotName

func _clear_label():
	$Button/field_slotName.text = ""
	
func _set_icon(filename):
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + filename)

func _clear_icon():
	$Button/sprite_itemIcon.texture = null
	
func _set_data(data):
	itemData = data
	
func _clear_data():
	itemData = null

func _set_slot(slotName):
	itemSlot = slotName
	
func _clear_vault_index():
	itemVaultIndex = -1 #might not need this 

func _set_disabled():
	$Button.disabled = true
	$Button.modulate = Color(0.5,0.5,0.5,1)
	$Button/sprite_itemIcon.modulate = Color(0.25,0.25,0.25)
	
func _set_enabled():
	$Button.disabled = false
	$Button.modulate = Color(1,1,1,1)
	$Button/sprite_itemIcon.modulate = Color(1,1,1)

func _render_vault(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/field_slotName.text = data.slot
	
func _render_tradeskill(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/field_slotName.hide()
	
func _render_camp_loot(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/field_slotName.hide()
	
func _render_quest_prize(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/field_slotName.hide()
	
func _clear_tradeskill():
	_clear_data()
	_clear_icon()
	_clear_label()
	
	
func _on_Button_pressed():
	if (global.inSwapItemState):
		#we are clicking on the destination button (the source button set global.inSwapItemState)
		
		var destinationItem = global.guildItems[itemVaultIndex]
		var sourceItem = global.guildItems[global.swapItemSourceIdx]
		#perform the swap 
		global.guildItems[itemVaultIndex] = sourceItem
		global.guildItems[global.swapItemSourceIdx] = destinationItem
		global.inSwapItemState = false
		#updating the source button's icon/label/etc has to be handled by the Vault parent,
		#since this button (the destination at this point) has no idea what button that was
		emit_signal("updateSourceButtonArt")
	else:
		#save a record of the previous button clicked for use in swapping items 
		global.lastItemButtonClicked = self
		global.browsingForSlot = itemSlot
		
		#only show the item popup if there is an item, otherwise go to the vault
		if (itemData):
			itemPopup._set_data(itemData)
			itemPopup._set_vault_index(itemVaultIndex)
			itemPopup.popup()
		else:
			if (global.currentMenu == "heroPage"):
				global.currentMenu = "vaultViaHeroPage"
			get_tree().change_scene("res://menus/vault.tscn")
