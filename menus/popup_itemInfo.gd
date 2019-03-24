extends WindowDialog
#popup_itemInfo.gd

var itemData = null
var vaultIndex = -1

signal itemDeletedOrMovedToVault
signal swappingItemWithAnother
signal updateStats
signal clearWildcardButton

onready var field_stat0 = $VBoxContainer/hbox_stats/vboxstats1/field_stat0
onready var field_stat1 = $VBoxContainer/hbox_stats/vboxstats1/field_stat1
onready var field_stat2 = $VBoxContainer/hbox_stats/vboxstats1/field_stat2
onready var field_stat3 = $VBoxContainer/hbox_stats/vboxstats2/field_stat3
onready var field_stat4 = $VBoxContainer/hbox_stats/vboxstats2/field_stat4
onready var field_stat5 = $VBoxContainer/hbox_stats/vboxstats2/field_stat5
onready var field_stat6 = $VBoxContainer/hbox_stats/vboxstats3/field_stat6
onready var field_stat7 = $VBoxContainer/hbox_stats/vboxstats3/field_stat7
onready var field_stat8 = $VBoxContainer/hbox_stats/vboxstats3/field_stat8

onready var field_itemName = $VBoxContainer/field_itemName
onready var field_itemID = $field_itemID
onready var sprite_itemIcon = $sprite_itemIcon

onready var field_slot = $VBoxContainer/HBoxContainer/VBoxContainer/field_slot
onready var field_noDrop = $VBoxContainer/HBoxContainer/VBoxContainer2/field_noDrop
onready var field_rarity = $VBoxContainer/HBoxContainer/VBoxContainer2/field_rarity

onready var field_improved = $VBoxContainer/field_improved

onready var field_armorOrDPS = $VBoxContainer/HBoxContainer/VBoxContainer/field_armorOrDPS

onready var field_classes = $VBoxContainer/field_classes

var classNameMap = {
	"any":"ANY",
	"warrior":"WAR",
	"cleric":"CLR",
	"druid":"DRU",
	"paladin":"PAL",
	"wizard":"WIZ",
	"ranger":"RNG",
	"rogue":"ROG",
	"necromancer":"NEC",
	"enchanter":"ENC",
	"bard":"BRD"
	}

func _ready():
	field_stat0.hide()
	field_stat1.hide()
	field_stat2.hide()
	field_stat3.hide()
	field_stat4.hide()
	field_stat5.hide()
	field_stat6.hide()
	field_stat7.hide()
	field_stat8.hide()

func _set_vault_index(idx):
	vaultIndex = idx
	
func _set_data(data):
	itemData = data
	_populate_fields()
	
func _populate_fields():
	#window_title = itemData.name #old way that puts title outside the art for some reason
	field_itemName.text = itemData.name

	sprite_itemIcon.texture = load("res://sprites/items/" + itemData.icon)
	field_slot.text = itemData.slot.capitalize()

	if (!itemData.noDrop):
		field_noDrop.text = "Tradeable"
	else:
		field_noDrop.text = "Binds on equip"
		
	if (itemData.rarity):
		field_rarity.text = str(itemData.rarity).capitalize()
		if (itemData.rarity == "uncommon"):
			field_rarity.add_color_override("font_color", colors.green)
		elif (itemData.rarity == "rare"):
			field_rarity.add_color_override("font_color", colors.blue) 
		elif (itemData.rarity == "epic"):
			field_rarity.add_color_override("font_color", colors.pink) 
	
	if (itemData.improved):
		field_improved.text = "Improved " + itemData.improvement
	else:
		field_improved.hide()
			
	print("popup_itemInfo.gd - itemID: " + str(itemData.itemID))
	if (itemData.itemID):
		field_itemID.text = str(itemData.itemID)
		field_itemID.add_color_override("font_color", colors.pink) 
		
	#figure out what stats this item gives
	if (itemData.slot != "tradeskill" && itemData.slot != "quest"):
		#an item gives armor or dps, but not both
		if (itemData.dps > 0):
			field_armorOrDPS.text = str(itemData.dps) + " DPS"
		elif (itemData.armor > 0):
			field_armorOrDPS.text = str(itemData.armor) + " Armor"
		else:
			field_armorOrDPS.hide()
			
		#there might be multiple class restrictions, so build a string
		var restrictionsStr = ""
		for i in range(itemData.classRestrictions.size()):
			# Behind the scenes, we use the full class name. But on an item
			# we use an abbreviation. Those abbreviations are only for display, 
			# so do the conversion here.
			var classNameLong = itemData.classRestrictions[i].to_lower()
			print(classNameMap[classNameLong])
			restrictionsStr += str(classNameMap[classNameLong]) + " "
		#$field_classes.text = "Class: " + str(itemData.classRestriction).capitalize()
		field_classes.text = "Classes: " + restrictionsStr
	
		var stats = []
		if (itemData.hpRaw > 0):
			stats.append("+" + str(itemData.hpRaw) + " hp")
		
		if (itemData.manaRaw > 0):
			stats.append("+" + str(itemData.manaRaw) + " mana")
		
		if (itemData.strength > 0):
			stats.append("+" + str(itemData.strength) + " STR")
			
		if (itemData.defense > 0):
			stats.append("+" + str(itemData.defense) + " DEF")
		
		if (itemData.intelligence > 0):
			stats.append("+" + str(itemData.intelligence) + " INT")
		
		if (itemData.regenRateHP > 0):
			stats.append("+" + str(itemData.regenRateHP) + " HP regen")
			
		if (itemData.regenRateMana > 0):
			stats.append("+" + str(itemData.regenRateMana) + " Mana regen")
			
		#display them (should just be the ones greater than 0)
		for i in range(stats.size()):
			find_node("field_stat" + str(i)).text = stats[i]
			find_node("field_stat" + str(i)).show()
			#get_node("field_stat" + str(i)).text = stats[i]
			#get_node("field_stat" + str(i)).show()
	else:
		field_armorOrDPS.hide()
		field_classes.hide()
		
func _set_buttons(showActionButton, showTrashButton, actionButtonStr):
	if (showActionButton):
		$button_action.show()
		$button_action.text = actionButtonStr
	else:
		$button_action.hide()
		
	if (showTrashButton):
		$button_trash.show()
	else:
		$button_trash.hide()
	
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
			global.currentMenu == "chronomancy" || 
			global.currentMenu == "alchemy" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "tailoring" ||
			global.currentMenu == "jewelcraft"):
		if (global.tradeskills[global.currentMenu].wildcardItemOnDeck):
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