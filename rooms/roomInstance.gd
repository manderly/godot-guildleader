extends Node2D
#roomInstance.gd - shared by all rooms

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func display_room_name(nameStr):
	$field_roomName.text = nameStr
