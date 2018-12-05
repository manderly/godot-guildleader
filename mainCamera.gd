extends Camera2D

func _input(event):
	if event is InputEventScreenDrag:
		var newCoord = Vector2(16, get_offset().y - event.relative.y)
		if (newCoord.y > global.mainScreenTop && newCoord.y < 0):
			set_offset(newCoord) #attempt at "scrolling" camera (new way)
			#self.move_local_y(event.relative.y) #inverse camera (old way)
			global.cameraPosition = newCoord
		elif (newCoord.y < global.mainScreenTop):
			var topCoord = Vector2(16, global.mainScreenTop)
			set_offset(topCoord)
			global.cameraPosition = topCoord
		elif (newCoord.y > 0):
			var bottomCoord = Vector2(16, 0)
			set_offset(bottomCoord)
			global.cameraPosition = bottomCoord

func _ready():
	pass
	
func set_cam_position():
	set_offset(global.cameraPosition)