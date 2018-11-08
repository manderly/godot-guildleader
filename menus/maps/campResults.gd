extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_resultsScrollBox = $MarginContainer/CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer
onready var field_lootItems = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer2

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
	for itemName in campData.campOutcome.lootedItems:
		print("Item name: " + itemName)
		var itemBox = preload("res://menus/itemButton.tscn").instance()
		var itemData = global.allGameItems[str(itemName)]
		itemBox._render_camp_loot(itemData)
		field_lootItems.add_child(itemBox)
		
	for event in campData.campOutcome.summary:
		var eventText = Label.new()
		eventText.text = str(event)
		field_resultsScrollBox.add_child(eventText)

func _on_button_collect_pressed():
	#todo: iterate through campData.campOutcome.lootTotal and give those items to guild
	for lootName in campData.campOutcome.lootTotal:
		if (lootName): #because some entries are null
			util.give_item_guild(lootName)
		
	for hero in campData.heroes:
		if (hero):
			hero.send_home()
	
	campData.heroes = [null, null, null, null]
	campData.inProgress = false
	campData.readyToCollect = false
	campData.campOutcome = {}
	
	get_tree().change_scene("res://menus/maps/forest.tscn")
		
	pass # replace with function body
