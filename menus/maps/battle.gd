extends Node2D


#  0   1
#    2   3
var heroPositions = {
	"0":{
		"x":25,
		"y":120
		},
	"1":{
		"x":100,
		"y":130
		},
	"2":{
		"x":50,
		"y":170
		},
	"3":{
		"x":125,
		"y":180
		},
	}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func populate_heroes(heroes):
	for i in heroes.size():
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(heroes[i]) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"]))
		heroScene.face_right()
		heroScene.set_display_params(false, true) #walking, show name 
		
		add_child(heroScene)
		
func set_background(filename):
	$TextureRect.texture = load(filename)