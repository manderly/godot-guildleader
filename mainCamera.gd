extends Camera2D

func _input(event):
	if event is InputEventScreenDrag:
		var newCoord = Vector2(16, get_offset().y - event.relative.y)
		set_offset(newCoord) #attempt at "scrolling" camera (new way)
		#self.move_local_y(event.relative.y) #inverse camera (old way)
		global.cameraPosition = newCoord

func _ready():
	pass
	
func set_cam_position():
	set_offset(global.cameraPosition)