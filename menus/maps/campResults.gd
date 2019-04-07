extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_resultsScrollBox = $MarginContainer/CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer
onready var field_lootItems = $MarginContainer/CenterContainer/VBoxContainer/vbox_prizes
onready var campLogPopup = $campLog
onready var campLog = $campLog/ScrollContainer/VBoxContainer

var campData = null
var battlePrint = false

func _ready():
	campData = global.activeCampData[global.selectedCampID]
	_populate_fields()

func _populate_fields():
	field_campName.text = campData.name
	field_campDescription.text = str(campData.description)
	
	#create item boxes for each item won
	var lootDictionaryWithCounts = {} #to track counts
	var uniqueLootNames = [] #to control how many unique items we actually display 
	for itemName in campData.campOutcome.lootedItemsNames:
		if (lootDictionaryWithCounts.has(itemName)):
			lootDictionaryWithCounts[itemName] += 1
		else:
			lootDictionaryWithCounts[itemName] = 1
			uniqueLootNames.append(itemName)
		
	for itemName in uniqueLootNames:
		var itemIconAndCountDisplay = preload("res://menus/smallItemDisplay.tscn").instance()
		var itemData = staticData.items[str(itemName)]
		itemIconAndCountDisplay._render_stacked_item(itemData, lootDictionaryWithCounts[itemName])
		itemIconAndCountDisplay._set_white()
		field_lootItems.add_child(itemIconAndCountDisplay)
		
	for event in campData.campOutcome.summary:
		var eventText = Label.new()
		eventText.text = str(event)
		field_resultsScrollBox.add_child(eventText)
		
	for event in campData.campOutcome.detailedPlayByPlay:
		var detailedEvent = Label.new()
		detailedEvent.text = str(event)
		campLog.add_child(detailedEvent)

func _on_button_collect_pressed():
	#todo: iterate through campData.campOutcome.lootedItems and give those items to guild
	for lootName in campData.campOutcome.lootedItemsNames:
		#todo: test that it accounts for multiples of same item 
		if (lootName): #because some entries are null
			util.give_item_guild(lootName)
		
	for hero in campData.heroes:
		#this should have all of them, not just the "live" ones 
		if (hero):
			hero.restore_hp_mana()
			hero.send_home()
	
	global.softCurrency += campData.campOutcome.scTotal
	 
	global.activeCampData[global.selectedCampID].endTime = -1
	global.activeCampData[global.selectedCampID].heroes = []
	global.activeCampData[global.selectedCampID].inProgress = false
	global.activeCampData[global.selectedCampID].readyToCollect = false
	global.activeCampData[global.selectedCampID].campHeroesSelected = 0
	global.activeCampData[global.selectedCampID].selectedDuration = 0
	global.activeCampData[global.selectedCampID].enableButton = ""
	
	for slot in campData.groupSize:
		global.activeCampData[global.selectedCampID].heroes.append(null)

	print("going back to " + global.returnToMap)
	if (global.returnToMap == "forest"):
		get_tree().change_scene("res://menus/maps/forest.tscn")
	elif (global.returnToMap == "coast"):
		get_tree().change_scene("res://menus/maps/coast.tscn")
	
func _on_button_detailedCombatLog_pressed():
	campLogPopup.popup()
