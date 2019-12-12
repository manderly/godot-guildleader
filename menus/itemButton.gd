extends Control
#itemButton.gd

onready var itemPopup = load("res://menus/popup_itemInfo.tscn").instance()
var itemData = null
var itemVaultIndex = -1 #only needed when this button is used on the vault page 
var itemSlot = null #used on heroPage to know what to filter by

var showActionButton = false
var showTrashButton = false
var actionButtonStr = "no string set!"

signal updateSourceButtonArt
signal updateStatsOnHeroPage

func _ready():
	#todo: use some math to center it
	itemPopup.connect("itemDeletedOrMovedToVault", self, "deletedOrRemoved_callback")
	itemPopup.connect("swappingItemWithAnother", self, "swapState_callback")
	itemPopup.connect("updateStats", self, "updateStats_callback") #middleman to pass signal up to heroPage.gd
	itemPopup.connect("clearWildcardButton", self, "_clear_tradeskill")
	$Button/field_vaultIdx.hide() #for debug purposes, shows the item's index 
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
	$Button/sprite_itemIcon.modulate = tints.ghost

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

func set_disabled(boolVal):
	if (!boolVal):
		$Button.disabled = false
		#$Button.modulate = Color(1,1,1,1)
		#$Button/sprite_itemIcon.modulate = Color(1,1,1)
	else:
		#false, button is enabled 
		$Button.disabled = true
		$Button.modulate = Color(0.5,0.5,0.5,1)
		$Button/sprite_itemIcon.modulate = Color(0.25,0.25,0.25)
		
func _render_item_sprite(data):
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	if (data.tint):
		$Button/sprite_itemIcon.modulate = tints[data.tint]
	else:
		$Button/sprite_itemIcon.modulate = Color(1,1,1,1)
		
func _render_hero_page(data):
	itemData = data
	_render_item_sprite(data)

func _render_bedroom_page(data):
	itemData = data
	_render_item_sprite(data)
	
func _render_vault(data):
	itemData = data
	_render_item_sprite(data)
	if (data.itemType == "arrow"):
		$Button/field_slotName.text = "Arrow"
	else:
		$Button/field_slotName.text = data.slot
	
func _render_tradeskill(data):
	itemData = data
	_render_item_sprite(data)
	$Button/field_slotName.show()
	$Button/field_slotName.text = itemData.name
	
func _render_currency(data): #pass "Coin" or "Chrono"
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/icons/chrono.png")
	$Button/field_slotName.show()
	$Button/field_slotName.text = "1 Chrono"
	
func _render_camp_loot(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/sprite_itemIcon.modulate = tints.ghost
	$Button/field_slotName.hide()
	
func _render_quest_prize(data):
	itemData = data
	$Button/sprite_itemIcon.texture = load("res://sprites/items/" + data.icon)
	$Button/sprite_itemIcon.modulate = tints.ghost
	$Button/field_slotName.hide()
	
func _clear_tradeskill():
	_clear_data()
	_clear_icon()
	_clear_label()

func _set_info_popup_buttons(actButton, trashButton, string):
	showActionButton = actButton
	showTrashButton = trashButton
	actionButtonStr = string
	
func _on_Button_pressed():
	if (global.inSwapItemState):
		#we are clicking on the destination button (the source button set global.inSwapItemState)
		global.vault.swap_item_positions(global.swapItemSourceIdx, itemVaultIndex)
		#updating the source button's icon/label/etc has to be handled by the Vault parent,
		#since this button (the destination at this point) has no idea what button that was
		emit_signal("updateSourceButtonArt")
	else:
		#save a record of the previous button clicked for use in swapping items 
		global.lastItemButtonClicked = self
		if (itemSlot == "bed0" || itemSlot == "bed1"):
			global.whichBed = itemSlot
			# we have to make this just "bed" so the vault shows us "bed" items
			global.browsingForSlot = "bed"
		else:
			global.browsingForSlot = itemSlot
		
		#only show the item popup if there is an item, otherwise go to the vault
		if (itemData):
			itemPopup._set_data(itemData)
			itemPopup._set_vault_index(itemVaultIndex)
			itemPopup._set_buttons(showActionButton, showTrashButton, actionButtonStr)
			itemPopup.popup()
		else:
			if (global.currentMenu == "heroPage"):
				global.currentMenu = "vaultViaHeroPage"
			elif (global.currentMenu == "bedroomPage"):
				global.currentMenu = "vaultViaBedroomPage"
			get_tree().change_scene("res://menus/vault.tscn")
