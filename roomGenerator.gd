extends Node
#roomGenerator.gd
#makes a new room instance and saves some params to it

func _ready():
	pass

func generate(type): #room type is a string = blacksmith, training, vault, warrior, bedroom, etc 
	var newRoom = load("res://rooms/room.gd").new()
	#newRoom.roomID = global.nextRoomID #don't know if we need an ID system, this is how it's done though
	newRoom.roomName = str(type) #user-facing name
	newRoom.roomType = str(type) #code-facing name 
	global.rooms.append(newRoom)
	
