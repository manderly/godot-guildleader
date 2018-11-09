extends Node2D

onready var questScrollList = $MarginContainer/CenterContainer/VBoxContainer/scroll/vbox
onready var field_questName = $MarginContainer/CenterContainer/VBoxContainer/field_questName
onready var field_questDescription = $MarginContainer/CenterContainer/VBoxContainer/field_questDescription

func _ready():
	var yVal = 0
	for quest in global.activeQuests:
		var questButton = preload("res://menus/questButton.tscn").instance()
		#questButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing) #todo: fix 
		questButton.set_quest_data(quest)
		questButton.set_position(Vector2(0, yVal))
		questButton.connect("updateQuest", self, "_change_displayed_quest")
		questScrollList.add_child(questButton)
		yVal += 40
	_change_displayed_quest()

func _change_displayed_quest():
	print("changing displayed quest")
	var quest = global.allGameQuests[global.selectedQuestID] #local copy 
	field_questName.text = quest.name
	field_questDescription.text = quest.text

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")