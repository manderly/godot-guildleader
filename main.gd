extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var guildMembers = []

func _ready():
	# these should be global variables
	$HUD.update_currency(150, 15)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	# Generate X number of heroes (default guild members for now) 
	var heroQuantity = 3
	var heroX = 100
	var heroY = 100
	for i in range(heroQuantity):
		# var newHero = Hero.new("hero #" + str(i), 1);
		var newHero = preload("res://hero.tscn").instance()
		newHero.set_name("hero #" + str(i))
		newHero.set_position(Vector2(heroX, heroY))
		newHero.set_level(1)
		guildMembers.append(newHero)
		add_child(newHero) #put it on stage (child of main) 
		heroX += 20
		heroY += 25
		
	#verify they were generated 
	print("Guild members are:")
	for i in range(heroQuantity):
		print(guildMembers[i].heroName)
		pass
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Quests_pressed():
	get_tree().change_scene("res://Button.tscn");
	print("test")
	
