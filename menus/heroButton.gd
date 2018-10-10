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
	print("data.atHome = " + str(data.atHome))
	print("data.staffedTo = " + data.staffedTo)
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = "Level " + str(data.level) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.xp) + "/" + str(global.levelXpData[data.level].total)
	if (data.atHome && data.staffedTo == ""):
		$field_available.text = "Available"
	elif (data.atHome && data.staffedTo == "quest"):
		$field_available.text = "Ready to go!"
	elif (data.atHome && data.staffedTo != ""): #to catch tradeskills 
		$field_available.text = "Busy (" + str(data.staffedTo.capitalize()) + ")"
		$Button.set_disabled(true)
	elif (!data.atHome && data.staffedTo == "quest"): #heroes aren't unavailable until quest begins
		$field_available.text = "Away (Quest)"
		$Button.set_disabled(true)

		
func make_button_empty():
	$field_heroName.text = "SELECT A HERO"
	$field_levelAndClass.text = ""
	$field_xp.text = ""
	$field_available.text = ""
	$sprite_hero.texture = null
	
func _on_Button_pressed():
	#distinguish between whether button is on roster or heroSelect menu or blacksmith
	if (global.currentMenu == "roster"):
		global.selectedHero = heroData
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "selectHeroForQuest"):
		heroData.staffedTo = "quest"
		#first, free up whoever is already in that spot (if anyone) 
		if (global.questHeroes[global.questButtonID]):
			global.questHeroes[global.questButtonID].atHome = true
		#assign this hero to this spot in the questHeroes array  
		global.questHeroes[global.questButtonID] = heroData
		global.questHeroesPicked += 1
		global.currentMenu = "questConfirm"
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