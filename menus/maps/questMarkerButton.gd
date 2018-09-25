extends TextureButton

var questId = null
var questData = null

func _ready():
	pass

func _set_data(idStr):
	questId = idStr
	questData = global.questData[idStr]
	$label_questName.text = questData.name
	
func _get_quest_id():
	return questId

func _on_questMarkerButton_pressed():
	global.currentQuest = global.questData[questId]
	global.currentMenu = "questConfirm"
	get_tree().change_scene("res://menus/questConfirm.tscn")