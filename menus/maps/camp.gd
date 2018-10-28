extends Node2D

onready var field_campName = $MarginContainer/CenterContainer/VBoxContainer/field_campName
onready var field_campDescription = $MarginContainer/CenterContainer/VBoxContainer/field_campDescription

onready var campData = null

func _ready():
	print(global.campData[global.selectedCampID])
	campData = global.campData[global.selectedCampID]
	_populate_fields()
	
func _populate_fields():
	field_campName.text = campData.name
	field_campDescription.text = campData.description


func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/forest.tscn")
