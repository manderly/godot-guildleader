extends Camera2D

func _ready():
	pass

func _input(event):
	if event is InputEventScreenDrag:
		self.move_local_y(event.relative.y)
