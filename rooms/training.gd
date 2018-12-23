extends "room.gd"
#training.gd
#inherits all of room's methods 

func _ready():
	draw_hero_and_button()

func draw_hero_and_button():
	if (global.training["training0"].hero):
		$Button.hide()
		#draw the hero
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(global.training["training0"].hero) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(280, 60))
		add_child(heroScene)
	else:
		$Button.text = "Train hero"

func _process(delta):
	pass

func _on_Button_pressed():
	global.currentMenu = "training"
	if (!global.training["training0"].hero):
		get_tree().change_scene("res://menus/heroSelect.tscn")
