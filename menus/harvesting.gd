extends Node2D
#harvestingConfirm.gd #
#the screen with the harvesting details, loot, and the hero the player has assigned to it 
onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()
onready var finishedItemPopup = preload("res://menus/popup_finishedItem.tscn").instance()

onready var field_skill = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/VBoxContainer/field_skill
onready var field_riskLevel = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/VBoxContainer/field_riskLevel

onready var field_heroName = $MarginContainer/centerContainer/VBoxContainer/VBoxContainer/field_heroName
onready var field_heroSkill = $MarginContainer/centerContainer/VBoxContainer/VBoxContainer/field_heroSkill
onready var field_heroRisk = $MarginContainer/centerContainer/VBoxContainer/VBoxContainer/field_heroRisk

onready var field_nodeName = $MarginContainer/centerContainer/VBoxContainer/field_nodeName
onready var button_pickHero = $MarginContainer/centerContainer/VBoxContainer/button_pickHero
onready var buttonBeginHarvest = $MarginContainer/centerContainer/VBoxContainer/button_begin
onready var field_timeElapsed = $MarginContainer/centerContainer/VBoxContainer/field_timeElapsed
onready var nodeGraphic = $MarginContainer/centerContainer/VBoxContainer/HBoxContainer/icon_nodeGraphic

var currentHarvest = null

func _ready():
	finishedItemPopup.connect("collectItem", self, "harvestItem_callback")
	add_child(finishNowPopup)
	add_child(finishedItemPopup)
	
	currentHarvest = global.activeHarvestingData[global.selectedHarvestingID]
	# give this one its own brand new prize array 
	currentHarvest.harvestedItems = []
	
	populate_fields(currentHarvest)
	
	if (currentHarvest.inProgress && !currentHarvest.readyToCollect):
		buttonBeginHarvest.text = "Stop " + currentHarvest.skillName
	
	#disable the begin quest button until enough heroes are assigned
	if (!currentHarvest.hero):
		buttonBeginHarvest.set_disabled(true)
	else:
		buttonBeginHarvest.set_disabled(false)
		
func try_harvest_chance(): 
	var random = randi()%100 #0 - 99
	var outcome = random + currentHarvest.hero.get_skill_level(currentHarvest.skillName)
	# just some fudged numbers for now 
	if (outcome > 50):
		return true
	else:
		return false
	# todo: account for "risk"
	
func _process(delta):
	#Displays how much time is left on the active quest 
	# "ready to collect" is set if something ends the harvest prematurely, ie: hero "dies" 
	if (currentHarvest.inProgress && !currentHarvest.readyToCollect):
		#set the display fields 
		if ((OS.get_unix_time() - currentHarvest.startTime) > 30):
			field_timeElapsed.set_text("Time Elapsed: " + util.format_time(OS.get_unix_time() - currentHarvest.startTime))
			if ((int(floor(OS.get_unix_time() - currentHarvest.startTime)) / 20)  > currentHarvest.harvestedItems.size()):
				print(str(OS.get_unix_time()) + ": 20 seconds have passed! Roll to see if we successfully mined something!")
				if (try_harvest_chance()):
					print(currentHarvest.hero.get_first_name() + " was successful!")
					currentHarvest.harvestedItems.append(1)
					print("Prize count is now: " + str(currentHarvest.harvestedItems.size()))
				else:
					if (currentHarvest.skillName == "Fishing"):
						print(currentHarvest.hero.get_first_name() + " didn't catch anything.")
					else:
						print(currentHarvest.hero.get_first_name() + " failed that attempt at " + currentHarvest.skillName.to_lower() + ".")
		elif ((OS.get_unix_time() - currentHarvest.startTime) < 8):
			field_timeElapsed.set_text("Time Elapsed: Just arrived!")
		elif ((OS.get_unix_time() - currentHarvest.startTime) < 16):
			field_timeElapsed.set_text("Time Elapsed: Getting settled...")
			
		#do not split the "currentHarvest.endtime - OS.get_unix_time into its own var 
		#it's too dumb and slow to keep up with it as a separate var and will just calculate to 0 

		#60 - 54 / 60 .... 6/60 = .01  = 1%.... this should work wtf 
		#print(100 * ((currentHarvest.timeToHarvest - timeLeft) / currentHarvest.timeToHarvest))
		buttonBeginHarvest.text = "DONE " + currentHarvest.skillName
	elif (currentHarvest.readyToCollect):
		field_timeElapsed.set_text("Hero finished here")
		buttonBeginHarvest.text = "COLLECT"
	else:
		field_timeElapsed.set_text("Not started")
	
func format_risk_string(heroLevel, riskLevel):
	var riskStr = ""
	if (heroLevel < riskLevel):
		riskStr = "Pretty high"
	elif (heroLevel == riskLevel):
		riskStr = "Risky"
	elif (heroLevel >= riskLevel):
		riskStr = "Low risk"
	return riskStr
	
func populate_fields(data):
	field_nodeName.text = data.name
	field_skill.text = str(data.skillName) + " skill level required: " + str(data.minSkill)
	field_riskLevel.text = "Risk level: " + str(data.riskLevel)
	nodeGraphic.texture = load("res://sprites/harvestNodes/" + data.icon)
	
	if (data.hero):
		field_heroName.text = data.hero.get_first_name()
		field_heroRisk.text = format_risk_string(data.hero.get_level(), data.riskLevel)
		_update_hero_skill_display()
	else:
		field_heroName.text = ""
		field_heroSkill.text = ""
		field_heroRisk.text = ""
	
	if (currentHarvest.inProgress):
		button_pickHero.set_disabled(true)

func _update_hero_skill_display():
	field_heroSkill.text = currentHarvest.skillName + " skill: " + str(currentHarvest.hero.skillHarvesting)
	
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
			currentHarvest.startTime = OS.get_unix_time()
			#start the timer attached to the quest object over in global
			#it has to be done there, or else will be wiped from memory when we close this particular menu 
			#global._begin_harvesting_timer(currentHarvest.timeToHarvest, currentHarvest.harvestingId)
			currentHarvest.inProgress = true
			button_pickHero.set_disabled(true)
			get_tree().change_scene("res://menus/forest.tscn")
	elif (currentHarvest.inProgress):
		_open_collect_result_popup()
	else:
		#bug: we get into this state if we let the quest finish while sitting on the questConfirm page 
		print("harvestingConfirm.gd error - not sure what state we're in")

func _open_collect_result_popup():
	#determine if we get a skillup and show or hide skillup text accordingly 
	if (util.determine_if_skill_up_happens(currentHarvest.hero.skillHarvesting, currentHarvest.minSkill+20)): #pass current skill, pass trivial level
		currentHarvest.hero.skillHarvesting += 1
		finishedItemPopup._set_skill_up(currentHarvest.hero, currentHarvest.skillName)
		_update_hero_skill_display()
	else:
		finishedItemPopup._show_skill_up_text(false)
		
	finishedItemPopup._set_icon(currentHarvest.icon)
	finishedItemPopup._set_item_name(currentHarvest.prizeItem1)
	finishedItemPopup.popup()
	
func harvestItem_callback():
	#accept the harvested item and give it to guild inventory 
	util.give_item_guild(currentHarvest.prizeItem1, 2) #todo: QUANTITIES NOT ACCOUNTED FOR YET 
	currentHarvest.endTime = -1
	currentHarvest.inProgress = false
	currentHarvest.readyToCollect = false
	currentHarvest.hero.send_home()
	currentHarvest.hero = null
	buttonBeginHarvest.text = "BEGIN"
	button_pickHero.set_disabled(false)
	populate_fields(currentHarvest)
	
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
