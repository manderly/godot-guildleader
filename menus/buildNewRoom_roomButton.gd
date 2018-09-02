extends Node2D

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_button_fields(data):
	$field_description.text = data.description
	$field_name.text = data.name

func _on_button_buildRoom_pressed():
	#deduct the cost (if you can afford it)
	if (global.softCurrency >= global.newRoomCost[global.roomCount]):
		global.softCurrency -= global.newRoomCost[global.roomCount]
		#add the new room to the global room array
		global.roomOrder.insert(global.roomCount, global.placeholderRoomScene) #second from last so the roof end piece is intact
		global.roomCount += 1 #can't just re-get the global size, it stays stale at 3
		#print("global.roomOrder.size() should go up by 1: " + str(global.roomOrder.size()))
		#return to main room
		get_tree().change_scene("res://main.tscn");
		#todo: for now, building a room is instant. But eventually, it should be on a timer.
	else:
		print("buildNewRoom_roomButton.gd: INSUFFICIENT FUNDS")
