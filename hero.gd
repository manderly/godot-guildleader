extends Node

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
	$field_levelAndClass.text = "Level " + str(heroLevel) + " " + heroClass
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

func _on_heroButton_released():
	print("clicked hero: " + heroName)

func _on_heroButton_pressed():
	print("clicked hero: " + heroName)

