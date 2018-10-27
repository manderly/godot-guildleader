extends Control

var harvestingId = null
var harvestingData = null

func _ready():
	pass

func _set_data(idStr):
	harvestingId = idStr
	harvestingData = global.harvestingData[idStr]
	
func _get_harvesting_id():
	return harvestingId


func _on_TextureButton_pressed():
	global.selectedHarvestingID = harvestingId #so we know which specific harvesting info to display in harvestConfirm
	global.currentMenu = "harvestingConfirm"
	get_tree().change_scene("res://menus/harvestingConfirm.tscn")
