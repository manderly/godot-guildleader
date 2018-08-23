extends KinematicBody2D

var heroName = "Default Name"
var heroClass = "NONE"
var level = -1
var xp = -1
var hp = -1
var mana = -1

var currentRoom = 0
var available = true

var walkDestX = -1
var walkDestY = -1
var target = Vector2()
var velocity = Vector2()
var speed = 20
var walking = false

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	$field_levelAndClass.text = "Level " + str(level) + " " + heroClass
	$field_xp.text = str(xp) + " xp"
	_start_idle_timer()


func _start_idle_timer():
	#idle for this random period of time and then start walking
	$idleTimer.set_wait_time(rand_range(5, 15))
	$idleTimer.start() #walk when the timer expires
	
func _start_walking():
	walking = true
	#print(heroName + " is picking a random destination")
	#pick a random destination to walk to (in the main room for now) 
	walkDestX = rand_range(mainRoomMinX, mainRoomMaxX)
	walkDestY = rand_range(mainRoomMinY, mainRoomMaxY)
	target = Vector2(walkDestX, walkDestY)
	#_physics_process(delta) handles the rest and determines when the heroes has arrived 
	
func _on_Timer_timeout():
	#print(heroName + " is done idling, time to walk!")
	_start_walking()

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        self.on_click()

func _physics_process(delta):
	if (walking):
		velocity = (target - position).normalized() * speed
		if (target - position).length() > 10:
			move_and_slide(velocity)
		else:
			#print(heroName + " has arrived at their random destination")
			walking = false
			$idleTimer.start()
		
func on_click():
	#this is a bad way to do it (should be based on unique IDs, not names)
	#but for now, loop through the heroes and find a name match to 
	#figure out what hero data we are viewing from the global hero array 
	for i in range(global.guildRoster.size()):
		if (global.guildRoster[i].heroName == heroName):
			global.selectedHero = global.guildRoster[i]
			global.currentMenu = "heroPage"
			get_tree().change_scene("res://menus/heroPage.tscn")

	
#I think this needs a refactor, it's just setting local vars not 
#pushing data into display fields 
func set_display_fields(data):
	heroName = data.heroName
	level = data.level
	xp = data.xp
	heroClass = data.heroClass
	currentRoom = data.currentRoom


