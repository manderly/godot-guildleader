extends Node2D
#questConfirm_heroButton.gd
#what happens when player clicks a "select hero" button in quest confirm screen 

var heroData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_hero_data(data):
	heroData = data
	populate_fields(heroData)

func populate_fields(data):
	#$field_heroName.text = data.heroName
	#$field_levelAndClass.text = "Level " + str(data.heroLevel) + " " + data.heroClass
	pass