extends TextureButton

var campId = null
var campData = null

func _ready():
	pass

func _set_data(idStr):
	campId = idStr
	campData = global.campData[idStr]
	$field_campName.text = campData.name
	
func _get_camp_id():
	return campId

func _on_campNodeButton_pressed():
	global.selectedCampID = campId #so we know which specific quest to display in questConfirm
	global.currentMenu = "campConfirm"
	get_tree().change_scene("res://menus/maps/camp.tscn")
