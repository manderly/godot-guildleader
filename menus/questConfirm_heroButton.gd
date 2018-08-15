extends Node2D
#questConfirm_heroButton.gd
#the square-shaped buttons on the questConfirm screen that hold hero names 

var buttonID = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_button_id(i):
	buttonID = i
	
func _on_Button_pressed():
	playervars.questButtonID = buttonID
	get_tree().change_scene("res://menus/heroSelect.tscn")
	
func display_hero_name(heroName):
	$Button.text = heroName