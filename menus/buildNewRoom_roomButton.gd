extends Node2D

var roomData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_button_fields(data):
	roomData = data
	$field_description.text = data.description
	$field_name.text = data.name

func _on_button_buildRoom_pressed():
	#check if you can afford this new room
	if (global.softCurrency >= global.newRoomCost[global.roomCount]):
		var roomToInsert = null
		if (roomData.name == "Bedroom"):
			global.guildCapacity += 2
			roomToInsert = global.bedroomScene
		elif (roomData.name == "Blacksmith"):
			roomToInsert = global.blacksmithScene
		elif (roomData.name == "Training"):
			roomToInsert = global.placeholderRoomScene
		elif (roomData.name == "Vault"):
			global.vaultSpace += 5
			global.guildItems.resize(global.vaultSpace) #otherwise, they fall out of sync and errors result
			roomToInsert = global.vaultScene
		else:
			roomToInsert = global.placeholderRoomScene
			
		global.softCurrency -= global.newRoomCost[global.roomCount]
		#add the new room to the global room array
		global.roomOrder.insert(global.roomCount, roomToInsert) #second from last so the roof end piece is intact
		global.roomCount += 1 #can't just re-get the global size, it stays stale at 3
		get_tree().change_scene("res://main.tscn");
		#todo: for now, building a room is instant. But eventually, it should be on a timer.
	else:
		print("buildNewRoom_roomButton.gd: INSUFFICIENT FUNDS")
