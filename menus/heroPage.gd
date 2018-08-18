extends Node2D

func _ready():
	populate_fields(global.selectedHero)
	
func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = str(data.heroLevel) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.heroXp) + "/" + str(global.levelXpData[data.heroLevel].total)
	$field_hp.text = str(data.heroHp)
	$field_mana.text = str(data.heroMana)

func _on_button_train_pressed():
	if (global.selectedHero.heroXp == global.levelXpData[global.selectedHero.heroLevel].total):
		print("Training this hero to next level")
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time 
		global.selectedHero.heroXp = 0
		global.selectedHero.heroLevel += 1
	else: 
		print("Need more xp - or pay diamonds to level up now!")


func _on_button_back_pressed():
	get_tree().change_scene("res://menus/roster.tscn")
