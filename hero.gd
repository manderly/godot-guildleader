extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# maybe use export before var? 
var heroName = "Default Name"
var heroLevel = 0
var heroXp = 0
var heroHp = 10
var heroClass = "NONE"
var currentRoom = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	$HBoxContainer/field_level.text = str(heroLevel)
	$HBoxContainer/field_class.text = heroClass
	pass
	
func set_name(newName):
	heroName = newName
	
func set_level(newLevel):
	heroLevel = newLevel
	
func set_class(newClass):
	print("newClass number came in as: " + str(newClass))
	if newClass == 1:
		heroClass = "Wizard"
	elif newClass == 2:
		heroClass = "Rogue"
	else:
		heroClass = "Warrior"
	
func set_current_room(roomNumber):
	currentRoom = roomNumber

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

