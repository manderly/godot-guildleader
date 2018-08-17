extends Button
#questConfirm_heroButton.gd
#the square-shaped buttons on the questConfirm screen that hold hero names 

var buttonID = null

func _ready():
	pass

func set_button_id(i):
	buttonID = i
	
func _on_Button_pressed():
	global.questButtonID = buttonID
	get_tree().change_scene("res://menus/heroSelect.tscn")
	
func display_hero_name(heroName):
	text = heroName