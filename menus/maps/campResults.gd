extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_resultsScrollBox = $MarginContainer/CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer

var campData = null

func _ready():
	campData = global.campData[global.selectedCampID]
	#print(campData.campOutcome)
	for battle in campData.campOutcome.battleRecord:
		var heroNames = []
		var mobNames = []
		
		#get just the name strings so we can do this print...
		for hero in battle.heroes:
			heroNames.append(hero.heroName)
			
		for mob in battle.mobs:
			mobNames.append(mob.mobName)
		
		print(str(heroNames) + " vs. " + str(mobNames) + ": " + battle.winner + " won")
	
	print(campData.campOutcome.lootTotal)
	_populate_fields()

func _populate_fields():
	field_campName.text = campData.name
	field_campDescription.text = campData.description
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
		hero.send_home()
	
	campData.heroes = [null, null, null, null]
	campData.inProgress = false
	campData.readyToCollect = false
	campData.campOutcome = {}
	
	get_tree().change_scene("res://menus/maps/forest.tscn")
		
	pass # replace with function body
