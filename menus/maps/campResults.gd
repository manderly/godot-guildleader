extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_resultsScrollBox = $MarginContainer/CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer
onready var field_lootItems = $MarginContainer/CenterContainer/VBoxContainer/vbox_prizes

var campData = null
var battlePrint = false

func _ready():
	campData = global.campData[global.selectedCampID]
	#print(campData.campOutcome)
	if (battlePrint):
		for event in campData.campOutcome.battleRecord:
			print(event)
	_populate_fields()

func _populate_fields():
	field_campName.text = campData.name
	field_campDescription.text = campData.description
	
	#create item boxes for each item won
	print(campData.campOutcome.lootedItemsNames)
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
		var itemData = global.allGameItems[str(itemName)]
		itemIconAndCountDisplay._render_stacked_item(itemData, lootDictionaryWithCounts[itemName])
		itemIconAndCountDisplay._set_white()
		field_lootItems.add_child(itemIconAndCountDisplay)
		
	for event in campData.campOutcome.summary:
		var eventText = Label.new()
		eventText.text = str(event)
		field_resultsScrollBox.add_child(eventText)

func _on_button_collect_pressed():
	#todo: iterate through campData.campOutcome.lootedItems and give those items to guild
	for lootName in campData.campOutcome.lootedItemsNames:
		#todo: test that it accounts for multiples of same item 
		if (lootName): #because some entries are null
			util.give_item_guild(lootName)
		
	for hero in campData.heroes:
		if (hero):
			hero.send_home()
	
	global.softCurrency += campData.campOutcome.scTotal
	
	campData.heroes = [null, null, null, null]
	campData.inProgress = false
	campData.readyToCollect = false
	campData.campOutcome = {}
	
	get_tree().change_scene("res://menus/maps/forest.tscn")
		
	pass # replace with function body
