extends Node2D

func _ready():
	populate_fields(global.selectedHero)
	
func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = str(data.heroLevel) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.heroXp) + "/100"
	$field_hp.text = str(data.heroHp)
	$field_mana.text = str(data.heroMana)