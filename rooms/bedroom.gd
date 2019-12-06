extends "room.gd"
#bedroom.gd
#inherits all of room's methods 

onready var field_occupancy = $field_occupancy

func _ready():
	var occupied = 0
	for i in global.bedrooms[roomID].size():
		# look for occupied "slots" in this bedroom;s array 
		if global.bedrooms[roomID][i] > 0:
			occupied+=1
			
	set_occupancy(occupied)

func draw_hero_and_button():
	pass
	
func set_occupancy(occupancy):
	field_occupancy.text = str(occupancy)+"/"+str(global.bedroomMaxOccupancy)