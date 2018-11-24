extends Node2D

var staggerY = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func populate_heroes(heroes):
	#how many heroes total?
	var heroesTotal = heroes.size()
	
	var heroX = 50
	var heroY = 100
	for hero in heroes:
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(hero) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroX, heroY))
		heroScene.face_right()
		
		add_child(heroScene)
		heroX += 75
		if (staggerY):
			heroY += 15
		else:
			heroY -= 15
		staggerY = !staggerY