extends Node2D
#questConfirm.gd
#the screen with the quest details, loot, and the heroes the player has assigned to it 
var util = load("res://util.gd").new()

onready var field_duration = $field_duration
onready var field_questName = $MarginContainer/centerContainer/vbox/centerTitleBanner/field_questName
onready var field_questDescription = $MarginContainer/centerContainer/vbox/centerDescription/field_questDescription
onready var field_timeRemaining = $MarginContainer/centerContainer/vbox/VBoxContainer/field_timeRemaining
onready var scRange = $MarginContainer/centerContainer/vbox/hbox_prizes_currency/field_scRange
onready var scSprite = $MarginContainer/centerContainer/vbox/hbox_prizes_currency/sprite_sc
onready var hcRange = $MarginContainer/centerContainer/vbox/hbox_prizes_currency/field_hcRange
onready var hcSprite = $MarginContainer/centerContainer/vbox/hbox_prizes_currency/sprite_hc
onready var buttonItem1 = $MarginContainer/centerContainer/vbox/hbox_prizes_items/button_item1
onready var buttonItem2 = $MarginContainer/centerContainer/vbox/hbox_prizes_items/button_item2
onready var buttonBeginQuest = $MarginContainer/centerContainer/vbox/VBoxContainer/CenterContainer/button_beginQuest
onready var heroButtonVbox = $MarginContainer/centerContainer/vbox/MarginContainer/scroll/vboxForHeroButtons
func _ready():
	#quest name, description
	populate_fields(global.currentQuest)
	if (global.questActive && !global.questReadyToCollect):
		buttonBeginQuest.text = "Finish now"
	
	#disable the begin quest button until enough heroes are assigned
	if (global.questHeroesPicked < global.currentQuest.groupSize):
		buttonBeginQuest.set_disabled(true)
	else:
		buttonBeginQuest.set_disabled(false)
		
	#create X number of hero buttons to hold selected heroes for this specific quest
	var buttonX = 0
	var buttonY = 0
	#draw a hero button for each hero in the roster
	for i in range(global.currentQuest.groupSize):
		#print(global.guildRoster[i]) #print all heroes (debug)
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		#if a hero has been picked via this button, display hero's name
		if (global.questHeroes[i] != null):
			heroButton.populate_fields(global.questHeroes[i])
		else:
			#otherwise, draw the button empty
			heroButton.make_button_empty()
			
		heroButton.set_button_id(i)
		heroButton.set_position(Vector2(buttonX, buttonY))
		heroButtonVbox.add_child(heroButton) 
		buttonY += 80
		
func _process(delta):
	#Displays how much time is left on the active quest 
	if (global.questActive && !global.questReadyToCollect):
		field_timeRemaining.set_text(util.format_time(global.questTimer.time_left))
	elif (!global.questActive && global.questReadyToCollect):
		field_timeRemaining.set_text("Quest time remaining: DONE!")
		buttonBeginQuest.text = "COLLECT PRIZES"
		#just kick player to collection screen automatically
		get_tree().change_scene("res://menus/questComplete.tscn")
	else:
		field_timeRemaining.set_text("Quest not started")
	
func populate_fields(data):
	field_questName.text = data.name
	field_questDescription.text = data.text
	field_duration.text = util.format_time(data.duration)
	
	if (data.scMin > 0):
		scRange.text = str(data.scMin) + " - " + str(data.scMax) + " coins"
	else:
		scSprite.hide()
		scRange.hide()
	
	if (data.hcMin > 0):
		hcRange.text = str(data.hcMin) + " - " + str(data.hcMax) + " diamonds"
	else:
		hcSprite.hide()
		hcRange.hide()
		
	#allGameItems is a dictionary of all the games items and you can get a particular item's data by name string
	if (data.item1):
		buttonItem1._set_icon(global.allGameItems[data.item1].icon)
		buttonItem1._set_data(global.allGameItems[data.item1])
		buttonItem1._set_label(str(data.item1Chance) + "%")
		
	if (data.item2):
		buttonItem2._set_icon(global.allGameItems[data.item2].icon)
		buttonItem2._set_data(global.allGameItems[data.item2])
		buttonItem2._set_label(str(data.item2Chance) + "%")

func _on_button_beginQuest_pressed():
	#this button lets you either begin the quest or finish it early for HC
	#case 1: no quest active, nothing ready to collect
	if (!global.questActive && !global.questReadyToCollect):
		if (global.questHeroesPicked < global.currentQuest.groupSize):
			print("Not enough groupies yet")
		else:
			#set everyone to away
			for i in range(global.questHeroesPicked):
				global.questHeroes[i].atHome = false
			
			global._begin_global_quest_timer(global.currentQuest.duration);
			get_tree().change_scene("res://main.tscn")
	#case 2: quest is active but not ready to collect 
	#todo: see if this can be done by just checking the status of the timer instead?
	elif (global.questActive && !global.questReadyToCollect): #quest is ready to collect
		#todo: this is just set up on a global level for now, but ideally it'll be quest-specific 
		get_node("quest_finish_now_dialog").popup()
	elif (!global.questActive && global.questReadyToCollect):
		#this is on the button, but really it should just kick you to the done screen automatically
		get_tree().change_scene("res://menus/questComplete.tscn")
	else:
		#bug: we get into this state if we let the quest finish while sitting on the questConfirm page 
		print("questConfirm.gd error - not sure what state we're in")

func _on_button_back_pressed():
	#clear out any heroes who were assigned to quest buttons
	if (!global.questActive && !global.questReadyToCollect):
		for i in range(global.questHeroes.size()):
			if (global.questHeroes[i] != null):
				global.questHeroes[i].atHome = true
				global.questHeroes[i].staffedTo = ""
				global.questHeroes[i] = null
				global.questHeroesPicked -= 1
				
	get_tree().change_scene("res://menus/maps/worldmap.tscn")

func _on_quest_finish_now_dialog_confirmed():
	if (global.hardCurrency > 0):
		global.hardCurrency -= 1
		global.questTimer.stop()
		global._on_questTimer_timeout()
		get_tree().change_scene("res://menus/questComplete.tscn")
	else:
		print("insufficient funds")
