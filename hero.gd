extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var heroName = "Default Name"
var heroLevel = 0
var heroXp = 0
var heroHp = 10
var heroClass = "Wizard"


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _init(heroNameVar):
	print("New hero constructed! " + heroNameVar)
	heroName = heroNameVar
