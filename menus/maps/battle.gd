extends Node2D

var fightCloudTimer = Timer.new()
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
		"x":135,
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
	show_fight_cloud(false)
		
	
func play_vignette(data):
	$label_battleN.hide()
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
	populate_heroes(data.campHeroes)
	var heroes = get_tree().get_nodes_in_group("heroes")
	# walk the heroes into position
	for i in heroes.size():
		var hero = heroes[i]
		hero.vignette_walk_to_point(heroPositions[str(i)]["x"], heroPositions[str(i)]["y"])

	yield(get_tree().create_timer(3.0), "timeout")
	
	
	#for each battle
	print("there will be " + str(data.battleSnapshots.size()) + " battles")
	for i in data.battleSnapshots.size():
	
		#todo: only continue to play if at least one hero is alive
		var battle = data.battleSnapshots[i]
			
		# spawn enenmies - enemies change every round, unlike heroes
		#todo: poof!
		populate_mobs(battle.mobs)
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
		heroes = get_tree().get_nodes_in_group("heroes")
		for hero in heroes:
			hero.vignette_hide_stats()
			hero.set_position(middleOfScreen)
			
		# for each mob on screen, move to middle
		var mobs = get_tree().get_nodes_in_group("mobs")
		#print(mobs)
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
			
		#print("mobs.size() is: " + str(mobs.size()))
		for i in mobs.size():
			var mob = mobs[i]
			mob.set_position(Vector2(mobPositions[str(i)]["x"], mobPositions[str(i)]["y"]))
		
		# update heroes and mobs hp
		yield(get_tree().create_timer(1.0), "timeout")
		
		#var activeHeroes = get_tree().call_group("heroes", "vignette_die")
		# remove dead heroes and mobs
		for i in heroes.size():
			var hero = heroes[i]
			#print("Am I dead? " + str(hero.get_first_name()) + " (hero ID:" + str(hero.heroID) + ") has this many hp left: " + str(battle.heroDeltas[hero.heroID].endHP))
			
			#display hp bars and animate the change in the total and % fill
			var deltas = battle.heroDeltas[hero.heroID]
			hero.vignette_show_stats()
			hero.vignette_update_hp_and_mana(deltas.startHP, deltas.endHP, deltas.totalHP, deltas.startMana, deltas.endMana, deltas.totalMana)
				
			#todo: animate the change simultaneously in all heroes 
			if (battle.heroDeltas[hero.heroID].endHP <= 0):
				hero.add_to_group("dyingHeroes")
			else:
				hero.add_to_group("recoveringHeroes")
				
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
				
			# wait (regen period between pulls)
			# todo: this time should be based on respawn time of this specific camp
			$label_battleN.show()
			$label_battleN.text = "Waiting for respawn"
			#print("waiting for respawn:" + str(data.respawnRate))
			
			# use a while loop to update hp/mana restore ticks
			# ie: camp needs 30 seconds to respawn
			# there will be 3 ticks of updates
			var recoveringHeroes = get_tree().get_nodes_in_group("recoveringHeroes")
			var regenTicks = data.respawnRate / 10
			for ticks in regenTicks:
				get_tree().call_group("recoveringHeroes", "vignette_recover_tick")
				#wait 10 seconds
				yield(get_tree().create_timer(10), "timeout")
		else:
			print("HEROES ALL DEAD! Leave the surviving mobs up.")
			$label_battleN.show()
			$label_battleN.text = "ALL HEROES DEFEATED :("
			break
	
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
		var heroScene = preload("res://baseEntity.tscn").instance()
		heroScene.set_script(preload("res://hero.gd"))
		heroScene.set_instance_data(heroes[i]) #put data from array into scene 
		heroScene._draw_sprites()
		heroScene.set_position(Vector2(heroPositionsOffscreen[str(i)]["x"], heroPositionsOffscreen[str(i)]["y"]))
		heroScene.face_right()
		heroScene.set_display_params(false, true) #no walking, show name 
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