extends Node2D

var timeUntilNextBattle = Timer.new()
var middleOfScreen = Vector2(150,150)
var deadHeroes = 0

#  0   1
#    2   3
var heroPositionsOffscreen = {
	# 200 less than starting positions
	"0":{
		"x":0, 
		"y":118
		},
	"1":{
		"x":75, 
		"y":140
		},
	"2":{
		"x":25, 
		"y":170
		},
	"3":{
		"x":105, 
		"y":180
		},
	}

var heroPositions = {
	"0":{
		"x":75,
		"y":118
		},
	"1":{
		"x":150,
		"y":140
		},
	"2":{
		"x":100,
		"y":170
		},
	"3":{
		"x":185,
		"y":180
		},
	}
	
var mobPositions = {
	"0":{
		"x":245,
		"y":120
		},
	"1":{
		"x":310,
		"y":140
		},
	"2":{
		"x":270,
		"y":180
		},
	"3":{
		"x":335,
		"y":210
		},
	}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func play_vignette(data):

	# each battle has heroes, mobs, start hp and end hp for each
	# each battle also has a duration (tbd by camp factors)
	
	# every battle and its outcome has already been decided and recorded in this data structure
	# this method just "plays it out"
	
	# put heroes on the stage - these heroes will persist battle-to-battle and get updated
	# and possibly killed and removed from later battles
	
	# these heroes should be recognized as a consistent group 
	populate_heroes(data.campHeroes)
	var heroes = get_tree().get_nodes_in_group("heroes")
	# walk the heroes onto the stage and have them keep walking 
	for i in heroes.size():
		var hero = heroes[i]
		hero.vignette_walk_to_point(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"])

	# 6/17/2021 - removed the concept of showing each battle in favor of a 
	# steady stream of mobs from the right
	
	#var battle = data.battleSnapshots[i]
	#populate_mobs(battle.mobs)
	#yield(get_tree().create_timer(1.0), "timeout")
			
	# create a group of mobs to represent this camp
	var mobs = get_tree().get_nodes_in_group("mobs")
	
		
	#print("mobs.size() is: " + str(mobs.size()))
	for i in mobs.size():
		var mob = mobs[i]
		mob.set_position(Vector2(mobPositions[str(i)]["x"], mobPositions[str(i)]["y"]))
		

func populate_heroes(heroes):
	for i in heroes.size():
		var heroScene = preload("res://baseEntity.tscn").instance()
		heroScene.set_script(preload("res://hero.gd"))
		heroScene.set_instance_data(heroes[i]) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroPositionsOffscreen[str(i)]["x"], heroPositionsOffscreen[str(i)]["y"]))
		heroScene.face_right()
		heroScene.set_display_params(true, true) #no walking, show name 
		heroScene.add_to_group("heroes")
		add_child(heroScene)
		
func populate_mobs(mobs):
	for i in mobs.size():
		var mobScene = preload("res://baseEntity.tscn").instance()
		mobScene.hide()
		mobScene.set_script(load("res://mob.gd"))
		mobScene.set_instance_data(mobs[i])
		var p_spawnCloud = load("res://particles/particles_spawnCloud.tscn").instance()
		var p_boomRing = load("res://particles/particles_boomRing.tscn").instance()
		p_spawnCloud.set_emitting(true)
		p_boomRing.set_emitting(true)
		mobScene.add_child(p_spawnCloud)
		mobScene.add_child(p_boomRing)
		mobScene.set_position(Vector2(mobPositions[str(i)]["x"], mobPositions[str(i)]["y"]))
		mobScene.set_display_params(false, true) #no walking, show name 
		mobScene.add_to_group("mobs")
		add_child(mobScene)
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().call_group("mobs", "show")
	get_tree().call_group("mobs", "_draw_sprites")
		
func set_background(filename):
	$TextureRect.texture = load(filename)