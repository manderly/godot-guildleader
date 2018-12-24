extends Node2D
#room.gd - shared by all rooms

var roomName = "Default Room Name" #filled in by constructor 
var roomType = "type is a string" #training, bedroom, etc 
var roomX = 0 #assigned when the room instance is placed on main.tscn 
var roomY = 0
var roomID = "" #must be a string, use mostly for training ie: training1

func _ready():
	display_room_name(roomName)

func display_room_name(nameStr):
	$field_roomName.text = roomName

func setX(xValue):
	roomX = xValue
	
func setY(yValue):
	roomY = yValue

#when we draw this room onto the main.tscn scene, we need to "re push" the 
#data into it from the rooms array entry
func set_instance_data(data):
	roomName = data.roomName
	roomType = data.roomType
	roomX = data.roomX
	roomY = data.roomY
	roomID = data.roomID
	
func save():
	print("saving this room:" + str(get_filename()))
	var room_save_data = {
		"filename":"res://rooms/*.tscn", #get_filename(), #"res://rooms/tailoring.tscn"
		"parent":get_parent().get_path(),
		"roomName":roomName,
		"roomType":roomType,
		"roomX":roomX,
		"roomY":roomY,
		"roomID":roomID
	}
	return room_save_data