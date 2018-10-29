extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_classesNeeded = $MarginContainer/CenterContainer/VBoxContainer/field_classesNeeded

onready var button_startCampShort = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampShort
onready var button_startCampMedium = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampMedium
onready var button_startCampLong = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampLong

onready var campData = null

func _ready():
	campData = global.campData[global.selectedCampID]
	_populate_fields()
	
func _populate_fields():
	field_campName.text = campData.name
	field_campDescription.text = campData.description
	button_startCampShort.text = "JOIN CAMP: " + str(util.format_time(campData.durationShort))
	button_startCampMedium.text = "JOIN CAMP: " + str(util.format_time(campData.durationMedium))
	button_startCampLong.text ="JOIN CAMP: " + str(util.format_time(campData.durationLong))
	
	#hero buttons
	#create X number of hero buttons to hold selected heroes for this specific quest
	var buttonX = 0
	var buttonY = 0
	for i in range(campData.groupSize):
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		if (campData.heroes[i] != null):
			heroButton.populate_fields(campData.heroes[i])
		else:
			heroButton.make_button_empty()
			
		heroButton.set_button_id(i)
		heroButton.set_position(Vector2(buttonX, buttonY))
		$MarginContainer/CenterContainer/VBoxContainer/vbox_heroButtons.add_child(heroButton) 
		buttonY += 80
	
	#don't make class recommendations until the player has picked a few heroes
	if (campData.campHeroesSelected >= 3):
		var classMakeupString = _calculate_recommended_classes()
		field_classesNeeded.text = classMakeupString
		
func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/forest.tscn")

func _calculate_recommended_classes():
	#set up object to count the archetypes we have picked 
	var classesObj = {
		"dps":0,
		"tank":0,
		"healer":0
	}
	#loop through the heroes we have 
	for hero in campData.heroes:
		if (hero):
			if (hero.heroClass == "Warrior" || hero.heroClass == "Paladin"):
				classesObj.tank += 1
			
			if (hero.heroClass == "Rogue" || hero.heroClass == "Wizard" || hero.heroClass == "Ranger" || hero.heroClass == "Druid"):
				classesObj.dps += 1
			
			if (hero.heroClass == "Cleric" || hero.heroClass == "Druid"):
				classesObj.healer += 1
	
	var classesNeededString = "This group could use "
	if (classesObj.healer == 0):
		classesNeededString += "a healer."
	elif (classesObj.tank == 0):
		classesNeededString += "a tank."
	elif (classesObj.dps == 0):
		classesNeededString += "at least one DPS."
	else:
		classesNeededString = "This group looks well-balanced!"
		
	return classesNeededString

func _on_button_startCampShort_pressed():
	_start_camp(campData.durationShort)

func _on_button_startCampMedium_pressed():
	_start_camp(campData.durationMedium)

func _on_button_joinCampLong_pressed():
	_start_camp(campData.durationLong)
	
func _start_camp(duration):
	campData.inProgress = true
	campData.readyToCollect = false
	campData.timer = Timer.new()
	campData.timer.set_one_shot(true)
	campData.timer.set_wait_time(duration)
	campData.timer.connect("timeout", self, "_on_campTimer_timeout", [campData.campId])
	campData.timer.start()
	get_tree().change_scene("res://menus/maps/forest.tscn")
