extends Node2D

var fightCloudTimer = Timer.new()
var timeUntilNextBattle = Timer.new()
var middleOfScreen = Vector2(150,150)
var deadHeroes = 0

#  0   1
#    2   3
var heroPositions = {
	"0":{
		"x":25,
		"y":118
		},
	"1":{
		"x":100,
		"y":140
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
	
	# put heroes on the stage - these heroes will persist battle-to-battle and get updated
	# and possibly killed and removed from later battles
	
	# these heroes should be recognized as a consistent group 
	print(data.campHeroes)
	populate_heroes(data.campHeroes)
	$label_battleN.hide()
	#todo: might be nice if heroes walked into position from offstage
	yield(get_tree().create_timer(2.0), "timeout")
	
	
	#for each battle
	print("there will be " + str(data.battleSnapshots.size()) + " battles")
	for i in data.battleSnapshots.size():
	
		#todo: only continue to play if at least one hero is alive
		var battle = data.battleSnapshots[i]
			
		# spawn enenmies
		#todo: poof!
		populate_mobs(battle.mobSprites)
		yield(get_tree().create_timer(1.0), "timeout")
		
		# print BATTLE N where the player can see it
		print("BATTLE " + str(i))
		$label_battleN.show()
		$label_battleN.text = "BATTLE " + str(i + 1)
		yield(get_tree().create_timer(2.0), "timeout")
	
		# clear text and pause a moment before jumping into the fray
		$label_battleN.hide()
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
		
		#var activeHeroes = get_tree().call_group("heroes", "vignette_die")
		# remove dead heroes and mobs
		for i in heroes.size():
			var hero = heroes[i]
			#print("Am I dead? " + str(hero.heroFirstName) + " (hero ID:" + str(hero.heroID) + ") has this many hp left: " + str(battle.heroDeltas[hero.heroID].endHP))
			
			#display hp bars and animate the change in the total and % fill
			var deltas = battle.heroDeltas[hero.heroID]
			hero.show_hp()
			hero.vignette_update_hp(deltas.startHP, deltas.endHP, deltas.totalHP)
				
			#todo: animate the change simultaneously in all heroes 
			if (battle.heroDeltas[hero.heroID].endHP <= 0):
				#print("yes, play dying animation and remove me")
				#hero.vignette_die()
				hero.add_to_group("dyingHeroes")

				
		var dyingHeroes = get_tree().call_group("dyingHeroes", "vignette_die")
		yield(get_tree().create_timer(3.0), "timeout")
		for dyingHero in get_tree().get_nodes_in_group("dyingHeroes"):
			dyingHero.queue_free()
			deadHeroes+=1
			#todo: also remove hero from heroes 
			
		# we always clear all the mobs UNLESS all the heroes are dead
		if (deadHeroes < heroes.size()):
			for mob in mobs:
				#Unlike heroes, mobs are just sprites
				#So remove the mob childs from the stage
				remove_child(mob)
		else:
			print("HEROES ALL DEAD! Leave the surviving mobs up.")
			$label_battleN.show()
			$label_battleN.text = "ALL HEROES DEFEATED :("
			#First, we have to figure out which mobs are not dead
			#So look in this battle's deltas
			#Todo: mob deltas not yet implemented in encounter generator
			
		# wait (regen period between pulls)
		# todo: this time should be based on respawn time of this specific camp
		$label_battleN.show()
		$label_battleN.text = "Waiting for respawn"
		print("waiting for respawn:" + str(data.respawnRate))
		yield(get_tree().create_timer(data.respawnRate), "timeout")
		
	# we've used up all the battles, print the outcome
	$label_battleN.show()
	$label_battleN.text = "Camp complete!"

		
	
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