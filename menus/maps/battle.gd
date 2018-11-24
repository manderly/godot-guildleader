extends Node2D


#  0   1
#    2   3
var heroPositions = {
	"0":{
		"x":25,
		"y":100
		},
	"1":{
		"x":100,
		"y":110
		},
	"2":{
		"x":50,
		"y":160
		},
	"3":{
		"x":125,
		"y":170
		},
	}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func populate_heroes(heroes):
	#how many heroes total?
	var heroesTotal = heroes.size()
	
	for i in heroes.size():
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(heroes[i]) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"]))
		heroScene.face_right()
		heroScene._battle_scene(true)
		
		add_child(heroScene)