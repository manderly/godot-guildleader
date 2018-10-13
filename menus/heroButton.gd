extends Node2D
#heroButton.gd
#Wide yellow button used in heroSelect, questConfirm, and roster

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
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = "Level " + str(data.level) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.xp) + "/" + str(global.levelXpData[data.level].total)
	if (data.atHome && data.staffedTo == ""):
		$field_available.text = "Available"
	elif (data.atHome && data.staffedTo == "quest"):
		$field_available.text = "Ready to go!"
		if (global.currentMenu == "selectHeroForQuest"):
			$Button.set_disabled(true)
	elif (data.atHome && data.staffedTo != ""): #to catch tradeskills 
		$field_available.text = "Busy (" + str(data.staffedTo.capitalize()) + ")"
		$Button.set_disabled(true)
	elif (!data.atHome && data.staffedTo == "quest"): #heroes aren't unavailable until quest begins
		$field_available.text = "Away (Quest)"
		$Button.set_disabled(true)
		
	#draw the hero
	var heroScene = preload("res://hero.tscn").instance()
	heroScene.set_instance_data(data) #put data from array into scene 
	heroScene._draw_sprites()
	heroScene.set_position(Vector2(14, 6))
	heroScene._just_for_display(true)
	add_child(heroScene)

		
func make_button_empty():
	$field_heroName.text = "SELECT A HERO"
	$field_levelAndClass.text = ""
	$field_xp.text = ""
	$field_available.text = ""
	
func _on_Button_pressed():
	#distinguish between whether button is on roster or heroSelect menu or blacksmith
	if (global.currentMenu == "roster"):
		global.selectedHero = heroData
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "selectHeroForQuest"):
		var currentQuest = global.questData[global.selectedQuestID]
		print(heroData.atHome)
		print(heroData.staffedTo)
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
			global.tradeskills[global.currentMenu].hero = heroData
			#todo: figure out where the blacksmith room is in the sequence and use that index
			global.currentMenu = "main"
			get_tree().change_scene("res://main.tscn")
		else:
			print("hero is busy")
	else:
		print("heroButton.gd - weird state")