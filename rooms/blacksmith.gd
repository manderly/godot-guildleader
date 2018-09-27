extends "room.gd"
#blacksmith.gd
#inherits all of room's methods 

func _ready():	
	pass

func _on_button_staff_pressed():
	global.currentMenu = "blacksmith"
	get_tree().change_scene("res://menus/heroSelect.tscn")
