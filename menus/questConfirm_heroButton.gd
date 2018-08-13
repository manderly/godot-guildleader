extends Node2D
#questConfirm_heroButton.gd

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed():
	print("going to hero selection screen")
	get_tree().change_scene("res://menus/heroSelect.tscn")
	#playervars.quest1Heroes.append(heroData.heroName)
	#get_tree().change_scene("res://menus/questConfirm.tscn");