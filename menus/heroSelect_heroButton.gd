extends Node2D
#questConfirm_heroButton.gd
#what happens when player clicks a "select hero" button in quest confirm screen 

var heroData = null

func _ready():
	pass

func set_hero_data(data):
	heroData = data
	populate_fields(heroData)

func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = "Level " + str(data.heroLevel) + " " + data.heroClass
	if (data.available):
		$field_available.text = "Available"
	else:
		$field_available.text = "Busy"
		$Button.set_disabled(true)

func _on_Button_pressed():
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