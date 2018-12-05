extends Button
#heroButton.gd
#Wide yellow button used in heroSelect, questConfirm, and roster

#don't use onready var shortcuts here, it just doesn't work at all 11/23/18 
#possible fix: remake from scratch because Button root used to be Node2D 

#refactor to use global.selectedHero?
var heroData = null
var buttonID = null

func _ready():
	pass

func set_button_id(i):
	buttonID = i
	
func set_hero_data(data):
	heroData = data
	populate_fields(heroData)

func populate_fields(data):
	$VBoxContainer/field_heroName.text = data.heroName
	$VBoxContainer/field_levelAndClass.text = "Level " + str(data.level) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.xp) + "/" + str(staticData.levelXpData[str(data.level)])
	if (data.atHome && data.staffedTo == ""):
		$VBoxContainer/field_available.text = "Available"
	elif (data.atHome && data.staffedTo == "camp"):
		$VBoxContainer/field_available.text = "Ready to go!"
		#if (global.currentMenu == "selectHeroForQuest"):
			#$Button.set_disabled(true)
	elif (data.atHome && data.staffedTo != ""): #to catch tradeskills 
		$VBoxContainer/field_available.text = "Busy (" + str(data.staffedTo.capitalize()) + ")"
		self.set_disabled(true)
	elif (!data.atHome && data.staffedTo == "quest"): #heroes aren't unavailable until quest begins
		$VBoxContainer/field_available.text = "Away (Quest)"
		self.set_disabled(true)
	elif(!data.atHome && data.staffedTo == "camp"):
		$VBoxContainer/field_available.text = "Away (Camp)"
		self.set_disabled(true)
	else:
		$VBoxContainer/field_available.text = "###BAD STATE"
		print("Check heroButton.gd line 19 hero state")
	
	$ProgressBar.set_value(100 * (data.xp / staticData.levelXpData[str(data.level)]))
	
	#draw the hero
	var heroScene = preload("res://hero.tscn").instance()
	heroScene.set_instance_data(data) #put data from array into scene 
	heroScene._draw_sprites()
	heroScene.set_position(Vector2(14, 6))
	heroScene.set_display_params(false, false) #walking, name displayed
	add_child(heroScene)

		
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
			global.currentMenu == "jewelcraft" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "alchemy" ||
			global.currentMenu == "tailoring"):
		if (heroData.atHome && heroData.staffedTo == ""):
			heroData.staffedTo = global.currentMenu
			heroData.currentRoom = 4
			print("heroButton.gd heroData:")
			print(str(heroData))
			global.tradeskills[global.currentMenu].hero = heroData
			#todo: figure out where the blacksmith room is in the sequence and use that index
			global.currentMenu = "main"
			get_tree().change_scene("res://main.tscn")
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
			global.currentMenu = "forest"
		else:
			print("can't pick this hero")
		get_tree().change_scene("res://menus/harvesting.tscn")
	elif (global.currentMenu == "camp"):
		global.campButtonID = buttonID
		global.currentMenu = "selectHeroForCamp"
		get_tree().change_scene("res://menus/heroSelect.tscn")
	elif (global.currentMenu == "selectHeroForCamp"):
		var currentCamp = global.activeCampData[global.selectedCampID]
		#first, free up whoever is already in that spot (if anyone) 
		print(currentCamp.heroes[global.campButtonID])
		
		if (currentCamp.heroes[global.campButtonID]):
			currentCamp.heroes[global.campButtonID].atHome = true
			currentCamp.heroes[global.campButtonID].staffedTo = ""
			currentCamp.campHeroesSelected -= 1
			
		#next, confirm this specific hero is available
		if (heroData.atHome && heroData.staffedTo == ""):
			currentCamp.heroes[global.campButtonID] = heroData
			currentCamp.heroes[global.campButtonID].staffedTo = "camp"
			currentCamp.campHeroesSelected += 1
			global.currentMenu = "camp"
		else:
			print("can't pick this hero")
		global.currentMenu = "camp"
		get_tree().change_scene("res://menus/maps/camp.tscn")
	else:
		print("heroButton.gd - can't figure out where to go!")