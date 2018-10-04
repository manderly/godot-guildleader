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
		global.softCurrency -= global.newRoomCost[global.roomCount]
		var roomToInsert = null
		print(roomData.name)
		if (roomData.name == "Bedroom"):
			global.guildCapacity += 2
			roomGenerator.generate("bedroom", true)
		elif (roomData.name == "Training"):
			roomGenerator.generate("training", true)
		elif (roomData.name == "Vault"):
			global.vaultSpace += 5
			global.guildItems.resize(global.vaultSpace) #otherwise, they fall out of sync and errors result
			roomGenerator.generate("vault", true)
		elif (roomData.name == "Class"):
			#Todo: which class you get is random but you can't get the same one twice
			#for now, it's always the warrior room
			roomGenerator.generate("warrior", true)
		elif (roomData.name == "Tradeskill"):
			print("buildNewRoom_roomButton.gd - building a tradeskill room")
			var randomTradeskillRoomNum = round(rand_range(0,4))
			if (randomTradeskillRoomNum == 0):
				print("blacksmith")
				roomGenerator.generate("blacksmith", true)
			elif (randomTradeskillRoomNum == 1):
				print("tailoring")
				roomGenerator.generate("tailoring", true)
			elif (randomTradeskillRoomNum == 2):
				print("jewelcraft")
				roomGenerator.generate("jewelcraft", true)
			elif (randomTradeskillRoomNum == 3):
				print("alchemy")
				roomGenerator.generate("alchemy", true)
			elif (randomTradeskillRoomNum == 4):
				print("fletching")
				roomGenerator.generate("fletching", true)
		else:
			print("buildNewRoom_roomButton.gd: invalid room selected, cannot generate room data")
		
		get_tree().change_scene("res://main.tscn");
		#todo: for now, building a room is instant. But eventually, it should be on a timer.
	else:
		print("buildNewRoom_roomButton.gd: INSUFFICIENT FUNDS")
