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
	print(data)
	if (data.available):
		$field_available.text = "Available"
	else:
		$field_available.text = "Busy"

func _on_Button_pressed():
	if (heroData.available):
		heroData.available = false #change status to busy 
		#first, free up whoever is already in that spot (if anyone) 
		if (playervars.questHeroes[playervars.questButtonID]):
			playervars.questHeroes[playervars.questButtonID].available = true
		#assign this hero to this spot in the questHeroes array  
		playervars.questHeroes[playervars.questButtonID] = heroData
		get_tree().change_scene("res://menus/questConfirm.tscn")
	else:
		print("Hero not available")