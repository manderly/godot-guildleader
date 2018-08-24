extends Node2D
#heroButton.gd
#used in heroSelect and roster

#refactor to use global.selectedHero?
var heroData = null

func _ready():
	pass

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
		$Button.set_disabled(true)

func _on_Button_pressed():
	#distinguish between whether button is on roster or heroSelect menu
	if (global.currentMenu == "roster"):
		global.selectedHero = heroData
		get_tree().change_scene("res://menus/heroPage.tscn")
	elif (global.currentMenu == "quests"):
		if (heroData.available):
			heroData.available = false #change status to busy 
			#first, free up whoever is already in that spot (if anyone) 
			if (global.questHeroes[global.questButtonID]):
				global.questHeroes[global.questButtonID].available = true
			#assign this hero to this spot in the questHeroes array  
			global.questHeroes[global.questButtonID] = heroData
			global.questHeroesPicked += 1
			get_tree().change_scene("res://menus/questConfirm.tscn")
		else:
			print("Hero not available")
	else:
		print("FREAK OUT AND DO NOTHING!!")