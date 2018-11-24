extends Node2D
#camp.gd

var encounterGenerator = load("res://encounterGenerator.gd").new()

onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_reccLevelRange = $MarginContainer/CenterContainer/VBoxContainer/field_recc
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription
onready var field_difficultyEstimate = $MarginContainer/CenterContainer/VBoxContainer/field_difficultyEstimate
onready var field_tipsOrProgress = $MarginContainer/CenterContainer/VBoxContainer/field_tipsOrProgress

onready var button_autoPickHeroes = $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/button_autoPickHeroes
onready var button_startCampShort = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampShort
onready var button_startCampMedium = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampMedium
onready var button_startCampLong = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/button_startCampLong

onready var vbox_heroButtons = $MarginContainer/CenterContainer/VBoxContainer/vbox_heroButtons

onready var progressBar = $MarginContainer/CenterContainer/VBoxContainer/ProgressBar

onready var campData = null
onready var heroButtons = []

var haveAlready = {
	"healer":0,
	"dps":0,
	"tank":0
}

func _ready():
	campData = global.campData[global.selectedCampID]
	if (!campData.inProgress):
		$battleScene.hide()
		
	add_child(finishNowPopup)
	_draw_hero_buttons()
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
		button_autoPickHeroes.disabled = true
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
		
func _draw_hero_buttons():
	#create X number of hero buttons to hold selected heroes for this specific quest
	for i in range(campData.heroes.size()):
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_button_id(i)
		heroButtons.append(heroButton)
		$MarginContainer/CenterContainer/VBoxContainer/vbox_heroButtons.add_child(heroButton) 
		
func _populate_fields():
	field_campName.text = campData.name
	
	var lowEndRange = 1
	var highEndRange = 50
	if (campData.level > 1):
		lowEndRange = campData.level - 1
	
	if (campData.level < 50):
		highEndRange = campData.level + 2
		
	field_reccLevelRange.text = "Recommended level range: " + str(lowEndRange) + " - " + str(highEndRange)
	field_campDescription.text = campData.description
	
	button_startCampShort.text = "JOIN CAMP: " + str(util.format_time(campData.durationShort))
	button_startCampMedium.text = "JOIN CAMP: " + str(util.format_time(campData.durationMedium))
	button_startCampLong.text ="JOIN CAMP: " + str(util.format_time(campData.durationLong))
	
	#FILL IN EXISTING hero buttons
	for i in campData.heroes.size():
		var hero = campData.heroes[i]
		if (hero):
			#get the same-indexed hero button instance and fill it in
			heroButtons[i].populate_fields(hero)
		else:
			#get the same-indexed hero button and empty it out 
			heroButtons[i].make_button_empty()
	
		#don't make class recommendations until the player has picked a few heroes
	if (campData.campHeroesSelected >= 3):
		print("calculating recommendations...")
		var difficultyString = _calculate_estimated_difficulty()
		field_difficultyEstimate.text = difficultyString
		var classMakeupString = _calculate_recommended_classes()
		field_tipsOrProgress.text = classMakeupString

		
func _on_button_back_pressed():
	if (!campData.inProgress):
		for i in campData.heroes.size():
			if (campData.heroes[i]):
				campData.heroes[i].send_home() #send this specific hero home
				campData.heroes[i] = null #and null his spot 
	get_tree().change_scene("res://menus/maps/forest.tscn")

func _calculate_estimated_difficulty():
	var estimate = "Looks like an even fight"
	var heroAverageLevel = 0
	var heroLevelSum = 0
	for hero in campData.heroes:
		if (hero):
			heroLevelSum += hero.level
	heroAverageLevel = heroLevelSum/campData.heroes.size()
	if (heroAverageLevel - 5 > campData.level):
		estimate = "Looks like an easy fight." #green con
	elif (heroAverageLevel > campData.level):
		estimate = "Looks like it's in your favor." #blue con
	elif (heroAverageLevel == campData.level): 
		estimate = "Looks like an even fight" #white con
	elif (heroAverageLevel + 5 < campData.level):
		estimate = "They're gonna mop the floor with you!" #red con
	elif (heroAverageLevel < campData.level):
		estimate = "Looks like a tough fight." #yellow con
	#get hero average level
	#get recommended level range
	#compare the two
	#communicate estimate to player
	return estimate
	
	
func _calculate_recommended_classes():
	calc_class_balance()
	var classesNeededString = "This group could use "
	if (haveAlready.healer == 0):
		classesNeededString += "a healer."
	elif (haveAlready.tank == 0):
		classesNeededString += "a tank."
	elif (haveAlready.dps == 0):
		classesNeededString += "at least one DPS."
	else:
		classesNeededString = "This group looks well-balanced!"
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
				print("camp.gd - not enough heroes")
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
			$battleScene.populate_heroes(campData.heroes)
			#todo: populate enemies 
			#todo: play out the fight scene 
			$battleScene.show()
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
		
		
func calc_class_balance():
	#zero it out
	haveAlready = {
		"healer":0,
		"dps":0,
		"tank":0
	}
	
	for hero in campData.heroes:
		if (hero != null):
			if (hero.get_archetype() == "healer"):
				haveAlready.healer += 1
			elif (hero.get_archetype() == "tank"):
				haveAlready.tank += 1
			elif (hero.get_archetype() == "dps"):
				haveAlready.dps += 1

func _on_button_autoPickHeroes_pressed():
	calc_class_balance() #make sure the class balance obj is up to date
		
	#for each empty hero slot
	for i in range(campData.heroes.size()):
		if (campData.heroes[i] == null):
			print("found a null spot to fill in!")
			#todo: sort heroes by xp first (want low xp heroes) 
			#look through all the available heroes
			for hero in global.guildRoster:
				if (hero.atHome == true && hero.staffedTo == ""):
					if (haveAlready.healer == 0 && hero.get_archetype() == "healer"):
						#todo: code duplication in heroSelect Button code
						campData.heroes[i] = hero #in progress
						campData.heroes[i].staffedTo = "camp"
						campData.campHeroesSelected += 1
						haveAlready.healer += 1
						break
					
					if (haveAlready.tank == 0 && hero.get_archetype() == "tank"):
						#todo: code duplication in heroSelect Button code
						campData.heroes[i] = hero #in progress
						campData.heroes[i].staffedTo = "camp"
						campData.campHeroesSelected += 1
						haveAlready.tank += 1
						break
					
					if (haveAlready.dps < 2 && hero.get_archetype() == "dps"):
						#todo: code duplication in heroSelect Button code
						campData.heroes[i] = hero #in progress
						campData.heroes[i].staffedTo = "camp"
						campData.campHeroesSelected += 1
						haveAlready.dps += 1
						break
						
	_populate_fields()		
			
	#heroButton.populate_fields(campData.heroes[i])
	#iterate through the available heroes
	#try to pick these archetypes: (tank), (healer), (dps), (dps)
	#try to pick heroes who need xp
	#try to pick high level heroes
	#only pick as many as are needed (skip taken spots)
