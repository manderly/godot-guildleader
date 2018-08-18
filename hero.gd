extends Area2D

var heroName = "Default Name"
var heroClass = "NONE"
var level = -1
var xp = -1
var hp = -1
var mana = -1

var currentRoom = 0
var available = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	$field_levelAndClass.text = "Level " + str(level) + " " + heroClass
	$field_xp.text = str(xp) + " xp"

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        self.on_click()
		
func on_click():
    print("Click")
	
#I think this needs a refactor, it's just setting local vars not 
#pushing data into display fields 
func set_display_fields(data):
	heroName = data.heroName
	level = data.level
	xp = data.xp
	heroClass = data.heroClass
	currentRoom = data.currentRoom

func _on_heroButton_pressed():
	print("clicked hero: " + heroName)

