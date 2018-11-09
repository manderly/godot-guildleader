extends Node2D

onready var questScrollList = $MarginContainer/CenterContainer/VBoxContainer/scroll/vbox

func _ready():
	
	var yVal = 0
	for quest in global.activeQuests:
		var questButton = preload("res://menus/questButton.tscn").instance()
		#questButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing) #todo: fix 
		questButton.set_quest_data(quest)
		questButton.set_position(Vector2(0, yVal))
		#questButton.connect("updateRecipe", self, "_update_ingredients")
		questScrollList.add_child(questButton)
		yVal += 40
	pass


func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")