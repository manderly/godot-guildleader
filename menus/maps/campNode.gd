extends TextureButton

var campId = null
var campData = null

func _ready():
	pass

func _set_data(idStr):
	campId = idStr
	campData = global.campData[idStr]
	$field_campName.text = campData.name
	
	var lowEndRange = 1
	var highEndRange = 50
	if (campData.level > 1):
		lowEndRange = campData.level - 1
	
	if (campData.level < 50):
		highEndRange = campData.level + 2
		
	$field_levelRange.text = "(" + str(lowEndRange) + " - " + str(highEndRange) + ")"
	
func _get_camp_id():
	return campId

func _on_campNodeButton_pressed():
	global.selectedCampID = campId #so we know which specific quest to display in questConfirm
	global.currentMenu = "camp"
	get_tree().change_scene("res://menus/maps/camp.tscn")
