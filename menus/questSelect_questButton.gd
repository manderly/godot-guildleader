extends Node2D

var questData = null

func _ready():
	pass
	
func set_quest_data(data):
	questData = data
	populate_fields(questData)

func populate_fields(data):
	$field_questName.text = data.name
	$field_questDuration.text = str(data.duration)
	$field_description.text = data.text
	$field_xpReward.text = str(data.xp)

func _on_Button_pressed():
	global.currentQuest = questData
	get_tree().change_scene("res://menus/questConfirm.tscn");
