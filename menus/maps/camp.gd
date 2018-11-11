extends Node2D
#camp.gd

var encounterGenerator = load("res://encounterGenerator.gd").new()

onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_tipsOrProgress = $MarginContainer/CenterContainer/VBoxContainer/field_tipsOrProgress

onready var button_startCampShort = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampShort
onready var button_startCampMedium = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampMedium
onready var button_startCampLong = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampLong

onready var progressBar = $MarginContainer/CenterContainer/VBoxContainer/ProgressBar

onready var campData = null

func _ready():
	campData = global.campData[global.selectedCampID]
	add_child(finishNowPopup)
	_populate_fields()
	_enable_and_disable_duration_buttons()
	
func _process(delta):
	if (!campData.inProgress && !campData.readyToCollect):
		progressBar.set_value(0)
	elif (campData.inProgress && !campData.readyToCollect):
		field_tipsOrProgress.text = str(util.format_time(campData.timer.time_left))
		progressBar.set_value(100 * ((campData.selectedDuration - campData.timer.time_left) / campData.selectedDuration))
	elif (campData.inProgress && campData.readyToCollect):
		field_tipsOrProgress.text = "DONE!"
		#todo: make it so only the correct button changes to collect 
		button_startCampShort.text = "COLLECT"
		button_startCampMedium.text = "COLLECT"
		button_startCampLong.text = "COLLECT"
		progressBar.set_value(100)


func _enable_and_disable_duration_buttons():
	var finishNowStr = "Finish Now"
	if (campData.inProgress):
		button_startCampShort.disabled = true
		button_startCampMedium.disabled = true
		button_startCampLong.disabled = true
		if (campData.enableButton == "short"): #short, medium, long as string
			button_startCampShort.disabled = false
			button_startCampShort.text = finishNowStr
		elif (campData.enableButton == "medium"):
			button_startCampMedium.disabled = false
			button_startCampMedium.text = finishNowStr
		elif (campData.enableButton == "long"):
			button_startCampLong.disabled = false
			button_startCampLong.text = finishNowStr
	else:
		button_startCampShort.disabled = false
		button_startCampMedium.disabled = false
		button_startCampLong.disabled = false
		
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
		print("calculating recommendations...")
		var classMakeupString = _calculate_recommended_classes()
		field_tipsOrProgress.text = classMakeupString

		
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
		
	print(classesNeededString)
	return classesNeededString

func _on_button_startCampShort_pressed():
	_start_camp(campData.durationShort, "short")

func _on_button_startCampMedium_pressed():
	_start_camp(campData.durationMedium, "medium")

func _on_button_joinCampLong_pressed():
	_start_camp(campData.durationLong, "long")


func _start_camp(duration, enableButtonStr):
	#this button lets you either begin the harvest or finish it early for HC
	#case 1: Begin harvest (no quest active, nothing ready to collect)
	if (!campData.inProgress && !campData.readyToCollect):
		var haveEnoughHeroes = true
		for slot in campData.heroes:
			if (slot == null):
				#todo: need a popup telling the player they need 4 heroes 
				haveEnoughHeroes = false
				break
		
		if (haveEnoughHeroes):
			#set everyone to away
			for hero in campData.heroes:
				hero.atHome = false
			#start the timer attached to the quest object over in global
			#it has to be done there, or else will be wiped from memory when we close this particular menu
			campData.selectedDuration = duration
			campData.enableButton = enableButtonStr
			global._begin_camp_timer(duration, campData.campId)
			_enable_and_disable_duration_buttons() #todo: potential race condition here, depends on props set by above line
	elif (campData.inProgress && !campData.readyToCollect):
		#todo: cost logic for speeding up a recipe is based on trivial level of recipe and time left 
		finishNowPopup._set_data("Camp", 1)
		finishNowPopup.popup()
	elif (campData.inProgress && campData.readyToCollect):
		#generate rewards
		#todo: put this somewhere else, it shouldn't be on the "collect" button because
		#the player can back out of the next page and re-run this code 
		campData.campOutcome = encounterGenerator.calculate_encounter_outcome(campData)
		get_tree().change_scene("res://menus/maps/campResults.tscn")
	else:
		print("camp.gd error - unhandled state")

func _on_button_autoPickHeroes_pressed():
	#for each empty hero slot
	for i in range(campData.heroes.size()):
		if (campData.heroes[i] == null):
			print("found an empty slot")
			#for hero in global.guildRoster:
				#if (hero.available && hero.heroClass == "Wizard"):
					#campData.heroes.append(hero) #in progress 
			
				#heroButton.populate_fields(campData.heroes[i])
	#iterate through the available heroes
	#try to pick these archetypes: (tank), (healer), (dps), (dps)
	#try to pick heroes who need xp
	#try to pick high level heroes
	#only pick as many as are needed (skip taken spots)
	pass # replace with function body
