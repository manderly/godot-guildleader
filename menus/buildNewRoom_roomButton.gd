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
	
	#disable this button if no tradeskill rooms are left to build
	if (roomData.name == "Tradeskill" && global.tradeskillRoomsToBuild.size() == 0):
		print("no tradeskills left to build")
		$button_buildRoom.disabled = true

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
			print(global.tradeskillRoomsToBuild)
			var tradeskillRand = round(rand_range(0,global.tradeskillRoomsToBuild.size() - 1))
			#this syntax is like saying: global.tradeskillRoomsToBuild["blacksmith"]
			roomGenerator.generate(global.tradeskillRoomsToBuild[tradeskillRand], true)
			#now remove that room from the array 
			global.tradeskillRoomsToBuild.remove(tradeskillRand)
		else:
			print("buildNewRoom_roomButton.gd: invalid room selected, cannot generate room data")
		
		get_tree().change_scene("res://main.tscn");
		#todo: for now, building a room is instant. But eventually, it should be on a timer.
	else:
		print("buildNewRoom_roomButton.gd: INSUFFICIENT FUNDS")
