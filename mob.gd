extends KinematicBody2D
# mob.gd

var mobName = "Default name"
var entityType = "mob"
var level = -1
var hp = -1
var hpCurrent = -1
var mana = -1
var manaCurrent = -1
var baseResist = -1
var dps = -1
var strength = -1
var dead = false
var sprite = "res://sprites/mobs/bat/bat_01.png"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func say_hello():
	print(mobName + " says hello, I'm level " + str(level) + ". I have " + str(hpCurrent) + "/" + str(hp) + "hp")