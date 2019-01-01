extends Camera2D

var isTouched = false
var relativeY = 0
var prevRelativeY = 0
var acceleration = 1.2
var deceleration = .25
var velocity = 0
const MAX_VELOCITY = 10
const X_OFFSET = -2 #bigger negative numbers push it to the right 

func move_camera(yVal):
	var newCoord = Vector2(X_OFFSET, get_offset().y - yVal)
	if (newCoord.y > global.mainScreenTop && newCoord.y < 0):
		set_offset(newCoord) #attempt at "scrolling" camera (new way)
		#self.move_local_y(event.relative.y) #inverse camera (old way)
		global.cameraPosition = newCoord
	elif (newCoord.y < global.mainScreenTop):
		var topCoord = Vector2(X_OFFSET, global.mainScreenTop)
		set_offset(topCoord)
		global.cameraPosition = topCoord
	elif (newCoord.y > 0):
		var bottomCoord = Vector2(X_OFFSET, 0)
		set_offset(bottomCoord)
		global.cameraPosition = bottomCoord

func _input(event):
	if event is InputEventScreenDrag:
		isTouched = true
		
		if (event.relative.y < 0):
			relativeY = -1
		elif (event.relative.y > 0):
			relativeY = 1
			
		if (velocity < MAX_VELOCITY):
			velocity += acceleration
			
		if (relativeY != prevRelativeY):
			velocity = 0
			
		prevRelativeY = relativeY
			
		move_camera(event.relative.y)
	elif !(event is InputEventScreenDrag or event is InputEventScreenTouch or event is InputEventMouseMotion):
		isTouched = false

func _ready():
	var newCoord = Vector2(X_OFFSET, get_offset().y)
	global.cameraPosition = newCoord
	
func _process(delta): #: (delta float) -> void
	if (!isTouched && velocity > 0):
		velocity -= deceleration
		move_camera(relativeY * velocity)
	
func set_cam_position():
	set_offset(global.cameraPosition)