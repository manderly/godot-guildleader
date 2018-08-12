extends Node2D

func _ready():
	populate_fields(playervars.currentQuest)
	
func populate_fields(data):
	$field_questName.text = data.name
	$field_questDescription.text = data.text
	

