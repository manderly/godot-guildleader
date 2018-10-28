extends Control

onready var field_nodeName = $field_nodeName
onready var textureButton = $TextureButton
var harvestingId = null
var harvestingData = null

func _ready():
	pass

func _set_data(idStr):
	harvestingId = idStr
	harvestingData = global.harvestingData[idStr]
	_populate_fields()
	
func _populate_fields():
	field_nodeName.text = harvestingData.name
	textureButton.texture_normal = load("res://sprites/harvestNodes/" + harvestingData.icon)
	
func _get_harvesting_id():
	return harvestingId

func _on_TextureButton_pressed():
	global.selectedHarvestingID = harvestingId #so we know which specific harvesting info to display in harvestConfirm
	global.currentMenu = "harvestingConfirm"
	get_tree().change_scene("res://menus/harvesting.tscn")
