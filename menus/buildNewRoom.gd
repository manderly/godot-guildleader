extends Node

func _ready():
	#print a vertically scrolling list of room buttons
	var buttonX = 0
	var buttonY = 100
	for i in range(global.roomTypeData.size()):
		#print(roomTypeData[i].name) #prints each quest name that was loaded
		var roomTypeButton = preload("res://menus/buildNewRoom_roomButton.tscn").instance()
		roomTypeButton.set_button_fields(global.roomTypeData[i])
		roomTypeButton.set_position(Vector2(buttonX, buttonY))
		add_child(roomTypeButton)
		buttonY += 130

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn");
