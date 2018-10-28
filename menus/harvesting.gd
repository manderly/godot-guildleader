extends Node2D
#harvestingConfirm.gd
#the screen with the harvesting details, loot, and the hero the player has assigned to it 
onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()
onready var finishedItemPopup = preload("res://menus/popup_finishedItem.tscn").instance()

onready var field_duration = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/VBoxContainer/field_duration
onready var field_skill = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/VBoxContainer/field_skill
onready var field_yield = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/VBoxContainer/field_yield
onready var field_heroName = $MarginContainer/centerContainer/VBoxContainer/VBoxContainer/field_heroName
onready var field_heroSkill = $MarginContainer/centerContainer/VBoxContainer/VBoxContainer/field_heroSkill
onready var field_nodeName = $MarginContainer/centerContainer/VBoxContainer/field_nodeName
onready var button_pickHero = $MarginContainer/centerContainer/VBoxContainer/button_pickHero
onready var buttonBeginHarvest = $MarginContainer/centerContainer/VBoxContainer/button_begin
onready var field_timeRemaining = $MarginContainer/centerContainer/VBoxContainer/field_timeRemaining
onready var progressBar = $MarginContainer/centerContainer/VBoxContainer/ProgressBar

var currentHarvest = null

func _ready():
	finishedItemPopup.connect("collectItem", self, "harvestItem_callback")
	add_child(finishNowPopup)
	add_child(finishedItemPopup)
	
	currentHarvest = global.harvestingData[global.selectedHarvestingID]
	populate_fields(currentHarvest)
	if (currentHarvest.inProgress && !currentHarvest.readyToCollect):
		buttonBeginHarvest.text = "Finish now"
	
	#disable the begin quest button until enough heroes are assigned
	if (!currentHarvest.hero):
		buttonBeginHarvest.set_disabled(true)
	else:
		buttonBeginHarvest.set_disabled(false)
		
func _process(delta):
	#Displays how much time is left on the active quest 
	if (currentHarvest.inProgress && !currentHarvest.readyToCollect):
		field_timeRemaining.set_text(util.format_time(currentHarvest.timer.time_left))
		#Displays how much time is left on the active recipe 

		#to get the percent, we need to know how long this recipe takes and how much time has elapsed
		#divide time elapsed by time needed to complete
		#progressBar.set_value(100 * ((currentHarvest.currentlyCrafting.totalTimeToFinish - currentHarvest.timer.time_left) / currentHarvest.currentlyCrafting.totalTimeToFinish))
		progressBar.set_value(100 * ((currentHarvest.timeToHarvest - currentHarvest.timer.time_left) / currentHarvest.timeToHarvest))
		buttonBeginHarvest.text = "FINISH NOW"
	elif (!currentHarvest.inProgress && currentHarvest.readyToCollect):
		field_timeRemaining.set_text("Harvest time remaining: DONE!")
		buttonBeginHarvest.text = "COLLECT"
	elif (currentHarvest.inProgress && currentHarvest.readyToCollect):
		buttonBeginHarvest.text = "COLLECT!"
		#buttonBeginHarvest.add_color_override("font_color", global.colorYellow) #239, 233, 64 yellow
		progressBar.set_value(100)
	else:
		field_timeRemaining.set_text("Harvest not started")
	
func populate_fields(data):
	field_nodeName.text = data.name
	field_duration.text = "Time to harvest: " + str(util.format_time(data.timeToHarvest))
	field_skill.text = "Harvesting skill required: " + str(data.minSkill)
	field_yield.text = "Yield: " + str(data.minQuantity) + " - " + str(data.maxQuantity)

	if (data.hero):
		field_heroName.text = data.hero.heroName
		_update_hero_skill_display()
	else:
		field_heroName.text = ""
		field_heroSkill.text = ""
	
	if (currentHarvest.inProgress):
		button_pickHero.set_disabled(true)

func _update_hero_skill_display():
	field_heroSkill.text = "Harvesting skill: " + str(currentHarvest.hero.skillHarvesting)
	
func _on_button_beginHarvesting_pressed():
	#this button lets you either begin the harvest or finish it early for HC
	#case 1: Begin harvest (no quest active, nothing ready to collect)
	if (!currentHarvest.inProgress && !currentHarvest.readyToCollect):
		if (!currentHarvest.hero):
			#todo: need a popup here
			print("Need to staff someone")
		else:
			#set everyone to away
			currentHarvest.hero.atHome = false
			#start the timer attached to the quest object over in global
			#it has to be done there, or else will be wiped from memory when we close this particular menu 
			global._begin_harvesting_timer(currentHarvest.timeToHarvest, currentHarvest.harvestingId)
			button_pickHero.set_disabled(true)
			get_tree().change_scene("res://menus/forest.tscn")
	#case 2: quest is active but not ready to collect 
	#todo: see if this can be done by just checking the status of the timer instead?
	elif (currentHarvest.inProgress && !currentHarvest.readyToCollect):
		finishNowPopup._set_data("Harvesting", 2)
		finishNowPopup.popup()
	elif (currentHarvest.inProgress && currentHarvest.readyToCollect):
		_open_collect_result_popup()
	else:
		#bug: we get into this state if we let the quest finish while sitting on the questConfirm page 
		print("harvestingConfirm.gd error - not sure what state we're in")

func _open_collect_result_popup():
	#determine if we get a skillup and show or hide skillup text accordingly 
	if (util.determine_if_skill_up_happens(currentHarvest.hero.skillHarvesting, currentHarvest.minSkill+20)): #pass current skill, pass trivial level
		currentHarvest.hero.skillHarvesting += 1
		finishedItemPopup._set_skill_up(currentHarvest.hero, "Harvesting")
		_update_hero_skill_display()
	else:
		finishedItemPopup._show_skill_up_text(false)
		
	finishedItemPopup._set_icon(currentHarvest.icon)
	finishedItemPopup._set_item_name(currentHarvest.prizeItem1)
	finishedItemPopup.popup()
	
func harvestItem_callback():
	#accept the harvested item and give it to guild inventory 
	util.give_item_guild(currentHarvest.prizeItem1) #todo: QUANTITIES NOT ACCOUNTED FOR YET 
	progressBar.set_value(0)
	currentHarvest.timer.stop()
	currentHarvest.inProgress = false
	currentHarvest.readyToCollect = false
	buttonBeginHarvest.text = "BEGIN"
	
func _on_button_back_pressed():
	#clear out any heroes who were assigned to quest buttons
	if (!currentHarvest.inProgress && !currentHarvest.readyToCollect):
		if (currentHarvest.hero):
			currentHarvest.hero.atHome = true
			currentHarvest.hero.staffedTo = ""
			currentHarvest.hero = null
				
	get_tree().change_scene("res://menus/maps/forest.tscn")

func _on_harvesting_finish_now_dialog_confirmed():
	if (global.hardCurrency > 0):
		global.hardCurrency -= 1
		currentHarvest.timer.stop()
		global._on_harvestingTimer_timeout(currentHarvest.harvestingId)
		#get_tree().change_scene("res://menus/harvestingComplete.tscn")
	else:
		#todo: need a global insufficient funds popup
		print("insufficient funds")


func _on_button_pickHero_pressed():
	global.currentMenu = "harvesting"
	get_tree().change_scene("res://menus/heroSelect.tscn")