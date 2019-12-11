extends Node
#roomGenerator.gd
#makes a new room instance and saves some params to it

func _ready():
	pass

func generate(type, playerBuilt): 
	#room type is a string = blacksmith, training, vault, warrior, bedroom, etc 
	#playerBuilt is a boolean that determines if we're just appending to the end or inserting one before the end
	#to preserve the location of the "top edge" piece
	
	var newRoom = load("res://rooms/room.gd").new()
	#newRoom.roomID = global.nextRoomID #don't know if we need an ID system, this is how it's done though
	newRoom.roomName = str(type) #user-facing name
	newRoom.roomType = str(type) #code-facing name 
	newRoom.roomID = str(type)
	if (!playerBuilt):
		global.rooms.append(newRoom)
	else:
		global.rooms.insert(global.rooms.size() - 1, newRoom)
		print("roomGenerator.gd: increasing roomCount by 1")
		global.roomCount += 1 
	
	if (type == "training"):
		newRoom.roomName += str(global.trainingRoomCount)
		newRoom.roomID = "training"+str(global.trainingRoomCount)
		global.trainingRoomCount += 1
	
	# every time a bedroom is added, add a key/value pair for it in the 
	# bedrooms object. It will hold the two heroes (by ID) who belong to that bedroom.
	
	# track who belongs to each bedroom here (by heroID)
	if (type == "bedroom"):
		newRoom.roomName += str(global.bedroomCount)
		newRoom.roomID = "bedroom"+str(global.bedroomCount)
		global.bedrooms[newRoom.roomID] = {
			"occupants":[0,0],
			"inventory":{
				"theme":"default",
				"bed0":null,
				"bed1":null,
				"rug":null,
				"decor":null
			}
		}
		global.bedroomCount += 1
