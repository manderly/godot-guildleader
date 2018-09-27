extends Node2D
var roomGenerator = load("res://roomGenerator.gd").new()

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
		print(roomData.name)
		if (roomData.name == "Bedroom"):
			global.guildCapacity += 2
			roomGenerator.generate("bedroom")
		elif (roomData.name == "Blacksmith"):
			roomGenerator.generate("blacksmith")
		elif (roomData.name == "Training"):
			roomGenerator.generate("training")
		elif (roomData.name == "Vault"):
			global.vaultSpace += 5
			global.guildItems.resize(global.vaultSpace) #otherwise, they fall out of sync and errors result
			roomGenerator.generate("vault")
		elif (roomData.name == "Class"):
			#Todo: which class you get is random but you can't get the same one twice
			#for now, it's always the warrior room
			roomGenerator.generate("warrior")
		else:
			print("buildNewRoom_roomButton.gd: invalid room selected, cannot generate room data")
			
		global.softCurrency -= global.newRoomCost[global.roomCount]
		#global.roomOrder.insert(global.rooms, roomToInsert) #second from last so the roof end piece is intact
		global.roomCount += 1 #can't just re-get the global size, it stays stale at 3
		get_tree().change_scene("res://main.tscn");
		#todo: for now, building a room is instant. But eventually, it should be on a timer.
	else:
		print("buildNewRoom_roomButton.gd: INSUFFICIENT FUNDS")
