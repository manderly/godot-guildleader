extends Node2D

var fightCloudTimer = Timer.new()
var timeUntilNextBattle = Timer.new()
var middleOfScreen = Vector2(150,150)
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
	
var mobPositions = {
	"0":{
		"x":245,
		"y":150
		},
	"1":{
		"x":310,
		"y":160
		},
	"2":{
		"x":270,
		"y":200
		},
	"3":{
		"x":335,
		"y":220
		},
	}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	show_fight_cloud(false)

func play_vignette(data):
	#handles the step by step iteration of the vignette data 
	# vignette data should come in as an array 
	# each index is an object representing a discrete battle
	# each battle has heroes, mobs, start hp and end hp for each
	# each battle also has a duration (tbd by camp factors)
	
	# every battle and its outcome has already been decided and recorded in this data structure
	# this method just "plays it out"
	
	#for now, just see if the data made it 
	print("this data came into battle scene")
	print(data)
	
	# put heroes on the stage - these heroes will persist battle-to-battle and get updated
	# and possibly killed and removed from later battles
	
	# these heroes should be recognized as a consistent group 
	print(data.campHeroes)
	populate_heroes(data.campHeroes)
	
	#for each battle
	print("there will be " + str(data.battles.size()) + " battles")
	for i in data.battles.size():
	
		
		#todo: only continue to play if at least one hero is alive
		var battle = data.battles[i]
		
		# print BATTLE N where the player can see it
		print("BATTLE " + str(i))
	
		# wait for mobs to spawn
		yield(get_tree().create_timer(3.0), "timeout")
			
		# spawn enenmies
		populate_mobs(battle.mobSprites)
		
		# pause before jumping into the fray
		yield(get_tree().create_timer(1.0), "timeout")
		
		# for each hero still on screen, move to middle
		var heroes = get_tree().get_nodes_in_group("heroes")
		for hero in heroes:
			hero.hide_hp()
			hero.set_position(middleOfScreen)
			
		# for each mob on screen, move to middle
		var mobs = get_tree().get_nodes_in_group("mobs")
		print(mobs)
		for mob in mobs:
			mob.set_position(middleOfScreen)
			
		# spawn the fight cloud
		show_fight_cloud(true)

		# wait (represents actual fighting)
		yield(get_tree().create_timer(6.0), "timeout")
		
		# despawn the fight cloud
		show_fight_cloud(false)
		
		# jump heroes and mobs back to their starting points
		for i in heroes.size():
			var hero = heroes[i]
			hero.set_position(Vector2(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"]))
			
		for i in mobs.size():
			var mob = mobs[i]
			mob.set_position(Vector2(mobPositions[str(i)]["x"], mobPositions[str(i)]["y"]))
		
		# update heroes and mobs hp
		yield(get_tree().create_timer(1.0), "timeout")
		
		# remove dead heroes and mobs
		for hero in heroes:
			print("Am I dead? " + str(hero.heroFirstName) + " (hero ID:" + str(hero.heroID) + ") has this many hp left: " + str(battle.heroDeltas[hero.heroID].endHP))
			
			#display hp bars and animate the change in the total and % fill
			var deltas = battle.heroDeltas[hero.heroID]
			hero.show_hp()
			hero.vignette_update_hp(deltas.startHP, deltas.endHP, deltas.totalHP)
				
			#todo: animate the change simultaneously in all heroes 
			if (battle.heroDeltas[hero.heroID].endHP <= 0):
				print("yes, play dying animation and remove me")
				hero.vignette_die()
				yield(get_tree().create_timer(3.0), "timeout")
				remove_child(hero)
			else:
				print("no, keep me in")
				
			
		for mob in mobs:
			print("Am I dead? " + str("mob name here"))
			mob.remove_from_group("mobs")
			#todo: remove dead mob 
		
		mobs.empty()
			
		# wait (regen period between pulls)
		yield(get_tree().create_timer(5.0), "timeout")
		
	
func show_fight_cloud(showBool):
	if (showBool):
		$fightcloud.show()
	else:
		$fightcloud.hide()
	

func populate_heroes(heroes):
	for i in heroes.size():
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_instance_data(heroes[i]) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"]))
		heroScene.face_right()
		heroScene.set_display_params(false, true) #walking, show name 
		heroScene.add_to_group("heroes")
		add_child(heroScene)
		
func populate_mobs(spriteFilenames):
	for i in spriteFilenames.size():
		var mobSprite = Sprite.new()
		mobSprite.texture = load("res://sprites/mobs/" + spriteFilenames[i])
		mobSprite.set_position(Vector2(mobPositions[str(i)]["x"], mobPositions[str(i)]["y"]))
		mobSprite.add_to_group("mobs")
		add_child(mobSprite)
		
func set_background(filename):
	$TextureRect.texture = load(filename)