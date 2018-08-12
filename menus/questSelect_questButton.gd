extends Node2D

var questData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func set_quest_data(data):
	questData = data
	populate_fields(questData)

func populate_fields(data):
	$field_questName.text = data.name
	$field_questDuration.text = str(data.duration)
	$field_description.text = data.text

func _on_Button_pressed():
	playervars.currentQuest = questData
	get_tree().change_scene("res://menus/questConfirm.tscn");
