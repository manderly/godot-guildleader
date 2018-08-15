extends Node

var heroName = "Default Name"
var heroLevel = 0
var heroXp = 0
var heroHp = 10
var heroClass = "NONE"
var currentRoom = 0
var available = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	$field_levelAndClass.text = "Level " + str(heroLevel) + " " + heroClass
	
func set_display_fields(data):
	heroName = data.heroName
	heroLevel = data.heroLevel
	heroClass = data.heroClass
	currentRoom = data.currentRoom

func _on_heroButton_released():
	print("clicked hero: " + heroName)

func _on_heroButton_pressed():
	print("clicked hero: " + heroName)

