extends Node2D
#questConfirm.gd

func _ready():
	#quest name, description
	populate_fields(playervars.currentQuest)
	
	#create X number of hero buttons to hold selected heroes for this specific quest
	var buttonX = 0
	var buttonY = 500
	for i in range(playervars.currentQuest.groupSize):
		var heroButton = preload("res://menus/questConfirm_heroButton.tscn").instance()
		heroButton.set_position(Vector2(buttonX, buttonY))
		add_child(heroButton)
		buttonX += 130
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text