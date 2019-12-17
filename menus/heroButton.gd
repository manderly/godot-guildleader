extends Button
#heroButton.gd
#Wide yellow button used in heroSelect, questConfirm, and roster

#don't use onready var shortcuts here, it just doesn't work at all 11/23/18 
#possible fix: remake from scratch because Button root used to be Node2D 

#refactor to use global.selectedHero?
var heroData = null
var buttonID = null

signal rapidTrain()

func _ready():
	pass

func set_button_id(i):
	buttonID = i
	
func set_hero_data(data):
	heroData = data
	populate_fields(heroData)

func populate_fields(data):
	$VBoxContainer/field_heroName.text = data.get_first_name() #just show first name on buttons
	$VBoxContainer/field_levelAndClass.text = "Level " + str(data.level) + " " + data.charClass
	
	if (data.level >= global.maxHeroLevel):
		$field_xp.text = "Max Level"
		$ProgressBar.hide()
	else:
		$field_xp.text = "XP: " + str(data.xp) + "/" + str(staticData.levelXpData[str(data.level)].total)
		$ProgressBar.set_value(100 * (data.xp / staticData.levelXpData[str(data.level)].total))
	
	if (data.atHome && data.dead):
		$VBoxContainer/field_available.text = "Dead"
		if (global.currentMenu != "roster"):
			self.set_disabled(true)
	elif (data.atHome && data.staffedTo == ""):
		$VBoxContainer/field_available.text = "Available"
	elif (data.atHome && data.staffedTo == "camp"):
		$VBoxContainer/field_available.text = "Ready to go!"
		#if (global.currentMenu == "selectHeroForQuest"):
			#$Button.set_disabled(true)
	elif (data.atHome && data.staffedTo != ""): #to catch tradeskills 
		$VBoxContainer/field_available.text = "Busy (" + str(data.staffedTo.capitalize()) + ")"
		self.set_disabled(true)
		if(data.atHome && data.staffedTo == "training"):
			$field_readyToTrain.text = "TRAINING TO " + str(data.level + 1)	
	elif (!data.atHome && data.staffedTo == "quest"): #heroes aren't unavailable until quest begins
		$VBoxContainer/field_available.text = "Away (Quest)"
		self.set_disabled(true)
	elif(!data.atHome && data.staffedTo == "camp"):
		$VBoxContainer/field_available.text = "Away (Camp " + data.staffedToID + ")"
		self.set_disabled(true)
	elif(!data.atHome && data.staffedTo == "harvesting"):
		$VBoxContainer/field_available.text = "Away (Harvesting " + data.staffedToID + ")"
		self.set_disabled(true)
	else:
		$VBoxContainer/field_available.text = "###BAD STATE"
		print("Check heroButton.gd line 19 hero state")
		
	if (global.currentMenu == "training"):
		#if we're trying to pick someone to train, disable anyone who is at max level
		if (data.level >= global.maxHeroLevel):
			self.set_disabled(true)
	

	#draw the hero
	var heroScene = preload("res://baseEntity.tscn").instance()
	heroScene.set_script(preload("res://hero.gd"))
	heroScene.set_instance_data(data) #put data from array into scene 
	heroScene._draw_sprites()
	heroScene.set_position(Vector2(14, 6))
	heroScene.set_display_params(false, false) #walking, name displayed
	add_child(heroScene)
	
	# tint the hero purple if dead
	if (data.dead):
		heroScene.modulate = Color(0.8, 0.7, 1)
		
	#ready to train text
	if (data.xp == staticData.levelXpData[str(data.level)].total):
		$field_readyToTrain.show()
	else:
		$field_readyToTrain.hide()

		
func make_button_empty():
	$VBoxContainer/field_heroName.text = "SELECT A HERO"
	$VBoxContainer/field_levelAndClass.text = ""
	$field_xp.text = ""
	$VBoxContainer/field_available.text = ""
	
func _on_Button_pressed():
	#distinguish between whether button is on roster or heroSelect menu or blacksmith
	if (global.currentMenu == "roster"):
		global.selectedHero = heroData
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "selectHeroForQuest"):
		var currentQuest = staticData.allQuestData[global.selectedQuestID]
		#first, free up whoever is already in that spot (if anyone) 
		if (currentQuest.heroes[global.questButtonID]):
			currentQuest.heroes[global.questButtonID].atHome = true
			currentQuest.heroes[global.questButtonID].staffedTo = ""
		
		#next, confirm this specific hero is available
		if (heroData.atHome == true && heroData.staffedTo == ""): 
			currentQuest.heroes[global.questButtonID] = heroData
			currentQuest.heroes[global.questButtonID].staffedTo = "quest"
			global.currentMenu = "questConfirm"
		else:
			print("can't pick this hero")
		get_tree().change_scene("res://menus/questConfirm.tscn")
	elif (global.currentMenu == "questConfirm"):
		global.questButtonID = buttonID
		global.currentMenu = "selectHeroForQuest"
		get_tree().change_scene("res://menus/heroSelect.tscn")
	elif (global.currentMenu == "blacksmithing" || 
			global.currentMenu == "chronomancy" || 
			global.currentMenu == "jewelcraft" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "alchemy" ||
			global.currentMenu == "cooking" ||
			global.currentMenu == "tailoring"):
		if (heroData.atHome && heroData.staffedTo == ""):
			heroData.staffedTo = global.currentMenu
			heroData.currentRoom = 4
			global.tradeskills[global.currentMenu].hero = heroData
			#todo: figure out where the blacksmith room is in the sequence and use that index
			global.currentMenu = "main"
			get_tree().change_scene("res://main.tscn")
		else:
			print("hero is busy")
	elif (global.currentMenu == "training"):
		if (heroData.atHome && heroData.staffedTo == ""):
			if (heroData.xp == staticData.levelXpData[str(heroData.level)].total):
				heroData.staffedTo = global.currentMenu
				heroData.staffedToID = global.currentRoomID
				global.training[global.currentRoomID].hero = heroData
				
				var timeToTrainToNextLevel = staticData.levelXpData[str(heroData.level)].trainingTime
				global.training[global.currentRoomID].endTime = OS.get_unix_time() + timeToTrainToNextLevel
				global.training[global.currentRoomID].inProgress = true
				global.training[global.currentRoomID].readyToCollect = false
				
				global.currentMenu = "main"
				global.currentRoomID = ""
				get_tree().change_scene("res://main.tscn")
			else:
				global.selectedHero = heroData
				emit_signal("rapidTrain")
		else:
			print("hero is busy")
	elif (global.currentMenu == "harvesting"):
		var currentHarvestNode = global.activeHarvestingData[global.selectedHarvestingID]
		#first, free up whoever is already in that spot (if anyone) 
		if (currentHarvestNode.hero):
			currentHarvestNode.hero.atHome = true
			currentHarvestNode.hero.staffedTo = ""
		#next, confirm this specific hero is available
		if (heroData.atHome == true && heroData.staffedTo == ""): 
			currentHarvestNode.hero = heroData
			currentHarvestNode.hero.staffedTo = "harvesting"
			currentHarvestNode.hero.staffedToID = currentHarvestNode.harvestingId
			global.currentMenu = "forest"
		else:
			print("can't pick this hero")
		get_tree().change_scene("res://menus/harvesting.tscn")
	elif (global.currentMenu == "camp"):
		global.campButtonID = buttonID
		global.currentMenu = "selectHeroForCamp"
		get_tree().change_scene("res://menus/heroSelect.tscn")
	elif (global.currentMenu == "selectHeroForCamp"):
		
		#!!! Update auto-pickhero code, too!!!!!!!!!!!!!!!!!!!!!!!
		
		var currentCamp = global.activeCampData[global.selectedCampID]
		#first, free up whoever is already in that spot (if anyone) 
		if (currentCamp.heroes[global.campButtonID]):
			currentCamp.heroes[global.campButtonID].send_home()
			currentCamp.campHeroesSelected -= 1
			
		#next, confirm this specific hero is available
		if (heroData.atHome && heroData.staffedTo == ""):
			currentCamp.heroes[global.campButtonID] = heroData
			currentCamp.heroes[global.campButtonID].staffedTo = "camp"
			currentCamp.heroes[global.campButtonID].staffedToID = currentCamp.campId
			currentCamp.campHeroesSelected += 1
			global.currentMenu = "camp"
		else:
			print("can't pick this hero")
		global.currentMenu = "camp"
		get_tree().change_scene("res://menus/maps/camp.tscn")
	else:
		print("heroButton.gd - can't figure out where to go!")