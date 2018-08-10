extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const Hero = preload("hero.gd")

var guildMembers = []

func _ready():
	# these should be global variables
	$HUD.update_currency(150, 15)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#attempting to populate the guild members array 
	var heroQuantity = 3
	for i in range(heroQuantity):
		var newHero = Hero.new("hero #" + str(i));
		guildMembers.append(newHero)
		
	print("Guild members are:")
	for i in range(heroQuantity):
		print(guildMembers[i].heroName)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Quests_pressed():
	get_tree().change_scene("res://Button.tscn");
	print("test")
	
