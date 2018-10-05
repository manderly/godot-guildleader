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
	if (data.available):
		$field_available.text = "Available"
	else:
		$field_available.text = "Busy"
		#only disable a busy hero if we're trying to pick a hero for a quest
		if (global.currentMenu == "selectHeroForQuest"):
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
		if (heroData.available):
			heroData.available = false #change status to busy 
			#first, free up whoever is already in that spot (if anyone) 
			if (global.questHeroes[global.questButtonID]):
				global.questHeroes[global.questButtonID].available = true
			#assign this hero to this spot in the questHeroes array  
			global.questHeroes[global.questButtonID] = heroData
			global.questHeroesPicked += 1
			global.currentMenu = "questConfirm"
			get_tree().change_scene("res://menus/questConfirm.tscn")
		else:
			global.logger(self, "Hero not available")
	elif (global.currentMenu == "questConfirm"):
		global.questButtonID = buttonID
		global.currentMenu = "selectHeroForQuest"
		get_tree().change_scene("res://menus/heroSelect.tscn")
	elif (global.currentMenu == "blacksmithing" || 
			global.currentMenu == "jewelcraft" ||
			global.currentMenu == "fletching" ||
			global.currentMenu == "alchemy" ||
			global.currentMenu == "tailoring"):
		if (heroData.available):
			#heroData.available = false #this hero is now busy as long as they're at the blacksmith
			heroData.currentRoom = 4
			global.tradeskills[global.currentMenu].hero = heroData
			#todo: figure out where the blacksmith room is in the sequence and use that index
			global.currentMenu = "main"
			get_tree().change_scene("res://main.tscn")
		else:
			print("hero is busy")
	else:
		print("FREAK OUT AND DO NOTHING!!")