extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# maybe use export before var? 
var heroName = "Default Name"
var heroLevel = 0
var heroXp = 0
var heroHp = 10
var heroClass = "Wizard"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	pass
	
func set_name(newName):
	heroName = newName
	
func set_level(newLevel):
	heroLevel = newLevel

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

