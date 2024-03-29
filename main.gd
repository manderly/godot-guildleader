extends Node
#main.gd

var heroGenerator = load("res://heroGenerator.gd").new()
var roomGenerator = load("res://roomGenerator.gd").new()

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

# node to add heroes to
# must exist in each scene that renders heroes who might walk over each other 
onready var heroesNode = $screen/YSort

var spawnLocs = {
	"0":{
		"x":120,
		"y":250
		},
	"1":{
		"x":220,
		"y":280
		},
	"2":{
		"x":320,
		"y":250
		},
	"3":{
		"x":140,
		"y":350
		},
	"4":{
		"x":240,
		"y":350
		},
	"5":{
		"x":340,
		"y":350
		},
	"6":{
		"x":1,
		"y":2
		},
	"7":{
		"x":10,
		"y":20
		},
	}

var graveyardLocs = {
	"0":{
		"x":120,
		"y":550
		},
	"1":{
		"x":220,
		"y":580
		},
	"2":{
		"x":320,
		"y":550
		},
	"3":{
		"x":140,
		"y":650
		},
	"4":{
		"x":240,
		"y":680
		},
	"5":{
		"x":340,
		"y":650
		},
	"6":{
		"x":310,
		"y":620
		},
	"7":{
		"x":310,
		"y":720
		},
	}
	
var questTimeLeft = -1

onready var roomsLayer = $screen/rooms

func generateStartingHeroes():
		
	var global_vars = get_node("/root/global")
	global_vars.add_to_group("PersistGlobals")

	heroGenerator.generate(global.guildRoster, "Wizard") #returns nothing, just puts them in the array reference that's passed in
	heroGenerator.generate(global.guildRoster, "Warrior")
	heroGenerator.generate(global.guildRoster, "Rogue")
	heroGenerator.generate(global.guildRoster, "Ranger")
	heroGenerator.generate(global.guildRoster, "Cleric")
	
	#Generate unrecruited heroes
	heroGenerator.generate(global.unrecruited, "Ranger")
	heroGenerator.generate(global.unrecruited, "Druid")
	
	#level them up a bit for testing purposes
	for hero in global.guildRoster:
		hero.make_level(18)
		
	# record all these names as in use
	# todo: refactor namesInUse to  be an object instead of an array 
	for hero in global.guildRoster:
		global.namesInUse.append(hero.get_first_name())
	
	for hero in global.unrecruited:
		global.namesInUse.append(hero.get_first_name())
	
	#generate starting rooms
	roomGenerator.generate("dummy", false) #placeholder for front yard (0)
	roomGenerator.generate("dummy", false) #placeholder for entrance hallway (1)
	roomGenerator.generate("chronomancy", false) 
	roomGenerator.generate("blacksmith", false)
	roomGenerator.generate("cooking", false)
	roomGenerator.generate("tailoring", false)
	roomGenerator.generate("woodcraft", false)
	roomGenerator.generate("training", false)
	roomGenerator.generate("bedroom", false)
	roomGenerator.generate("vault", false)
	roomGenerator.generate("bedroom", false)
	roomGenerator.generate("bedroom", false)
	roomGenerator.generate("topEdge", false)
	
	# must come after room generation
	# so the starting heroes belong to bedrooms by default 
	for hero in global.guildRoster:
		hero.auto_assign_bedroom()
	
	util.give_quest("test09")
	util.give_quest("test10")
	util.give_quest("azuricite_quest01")
	util.give_quest("quest_falls03")
	global.selectedQuestID = "test09"

	global.initDone = true

func _ready():
	randomize()
	global.currentMenu = "main"
	#load_game()
	# Generate default guildmembers and default rooms
	if (global.initDone == false):
		generateStartingHeroes()
	else:
		print("loaded game")

	#restore saved camera position
	$screen/mainCamera.set_cam_position()
		
	draw_HUD()
	$HUD/hbox/field_guildCapacity.text = str(global.guildRoster.size()) + "/" + str(global.guildCapacity)
	determine_atHome_positions()
	draw_heroes()
	draw_rooms()
	
func draw_HUD():
	$HUD.update_currency(global.softCurrency, global.hardCurrency)
	$screen/field_guildName.text = global.guildName + " Guild Hall"
	
func _save_hero_locations():
	#save the x and y of every hero currently on the screen
	for hero in global.onscreenHeroes:
		hero.save_current_position()
	
func _on_Map_pressed():
	_save_hero_locations()
	global.currentMenu = "worldmap"
	get_tree().change_scene("res://menus/maps/worldmap.tscn");
	
func _on_Quests_pressed():
	_save_hero_locations()
	global.currentMenu = "quests"
	get_tree().change_scene("res://menus/activeQuests.tscn");

func _on_Vault_pressed():
	_save_hero_locations()
	global.currentMenu = "vault"
	get_tree().change_scene("res://menus/vault.tscn");
	
func _on_Roster_pressed():
	_save_hero_locations()
	global.currentMenu = "roster"
	get_tree().change_scene("res://menus/roster.tscn");
	
func _process(delta):
	#var currentTime = OS.get_unix_time()
	#if (currentTime < global.testTimerEndTime):
	#	print(global.testTimerEndTime - currentTime)
	#else:
	#	print("timer done")
	pass
	
func determine_atHome_positions():
	var now = OS.get_unix_time()
	# let's say now is 61, and the last shuffle was at 0
	# if now - last shuffle > 60, time to shuffle
	if (global.lastIdlePositionShuffle == 0 || (now - global.lastIdlePositionShuffle > 600)):
		# take all the atHome heroes and assign some to be in the main hall
		# and some to be in their bedrooms. This is just for visual purposes
		for i in range(global.guildRoster.size()):
			#for each hero who is at home, give him a 50/50 chance of being in his room
			var thisHero = global.guildRoster[i]
			if (thisHero.atHome && thisHero.staffedTo == ""):
				# 50/50 chance of showing in bedroom instead of main hall 
				var idleInNum = randi()%2+1 #1-2
				if (idleInNum == 1):
					thisHero.idleIn="bedroom"
					# bedroom.gd code will take it from here when drawRooms is called 
				else:
					thisHero.idleIn="main"
		global.lastIdlePositionShuffle = now
			
func draw_heroes():
	var heroX = -1
	var heroY = -1
	global.onscreenHeroes = []
	
	for i in range(global.guildRoster.size()):
		#draw heroes who are "atHome"
		var thisHero = global.guildRoster[i]
		if (thisHero.atHome && thisHero.staffedTo == "" && thisHero.idleIn != "bedroom"):
			#we only need to make a new instance if this hero
			#is "wandering" the guildhall
			var heroScene = load("res://baseEntity.tscn").instance()
			heroScene.set_script(preload("res://hero.gd"))
			heroScene.set_instance_data(global.guildRoster[i]) #put data from array into scene 
			heroScene._draw_sprites()
			#print(global.guildRoster[i].heroName + " wants to be at " + str(global.guildRoster[i].savedPosition))
			if (thisHero.savedPositionX == -1):
				heroX = spawnLocs[str(i)]["x"]
				heroY = spawnLocs[str(i)]["y"]
				
				#global.guildRoster[i].savedPositionX = heroX
				#global.guildRoster[i].savedPositionY = heroY
				
				#todo: check if hero dead, and spawn in graveyard if so
				#heroX = graveyardLocs[str(i)]["x"]
				#heroY = graveyardLocs[str(i)]["y"]
			else:
				heroX = global.guildRoster[i].savedPositionX #rand_range(mainRoomMinX, mainRoomMaxX)
				heroY = global.guildRoster[i].savedPositionY #rand_range(mainRoomMinY, mainRoomMaxY)
				if (global.guildRoster[i].savedFacing == "left"):
					heroScene.face_left()
				elif (global.guildRoster[i].savedFacing == "right"):
					heroScene.face_right()
					
			if (thisHero.dead):
				heroScene.ghost_mode(true)
			else:
				heroScene.ghost_mode(false)
			heroScene.set_position(Vector2(heroX, heroY))
			heroScene.set_display_params(true, true) #walking, show name
			global.onscreenHeroes.append(heroScene)
			heroesNode.add_child(heroScene)
			
	#draw unrecruited heroes outside the base
	for i in range(global.unrecruited.size()):
		if (global.unrecruited[i].savedPositionX == -1):
			heroX = rand_range(150, 380)
			heroY = rand_range(650, 820)
		else:
			heroX = global.unrecruited[i].savedPositionX #rand_range(150, 380)
			heroY = global.unrecruited[i].savedPositionY #rand_range(650, 820)
			
		var heroScene = load("res://baseEntity.tscn").instance()
		heroScene.set_script(preload("res://hero.gd"))
		heroScene.set_position(Vector2(heroX, heroY))
		heroScene.set_instance_data(global.unrecruited[i])
		heroScene._draw_sprites()
		heroScene.set_display_params(true, true) #walking, show name
		global.onscreenHeroes.append(heroScene)
		add_child(heroScene)

func draw_rooms():
	#the room data is kept in global.rooms 
	#use that data to draw the instances into main.tscn 
	var roomX = 0
	var roomY = 0 #11 #43
	for i in range(global.rooms.size()):
		#rooms are different from heroes
		#heroes, all of them share one scene (hero.tscn)
		#rooms, they're all their own individual scenes
		#so we have to know what room we're making before we pick the correct scene
		var roomScene = null
		if (global.rooms[i].roomType == "dummy"):
			pass
		else:
			if (global.rooms[i].roomType == "bedroom"):
				roomScene = load("res://rooms/bedroom.tscn").instance()
			elif (global.rooms[i].roomType == "training"):
				roomScene = load("res://rooms/training.tscn").instance()
			elif (global.rooms[i].roomType == "warrior"):
				roomScene = load("res://rooms/warrior.tscn").instance()
			elif (global.rooms[i].roomType == "vault"):
				roomScene = load("res://rooms/vault.tscn").instance()
			elif (global.rooms[i].roomType == "alchemy"):
				roomScene = load("res://rooms/alchemy.tscn").instance()
			elif (global.rooms[i].roomType == "blacksmith"):
				roomScene = load("res://rooms/blacksmith.tscn").instance()
			elif (global.rooms[i].roomType == "chronomancy"):
				roomScene = load("res://rooms/chronomancy.tscn").instance()
			elif (global.rooms[i].roomType == "cooking"):
				roomScene = load("res://rooms/cooking.tscn").instance()
			elif (global.rooms[i].roomType == "tailoring"):
				roomScene = load("res://rooms/tailoring.tscn").instance()
			elif (global.rooms[i].roomType == "jewelcraft"):
				roomScene = load("res://rooms/jewelcraft.tscn").instance()
			elif (global.rooms[i].roomType == "woodcraft"):
				roomScene = load("res://rooms/woodcraft.tscn").instance()
			elif (global.rooms[i].roomType == "topEdge"):
				roomScene = load("res://rooms/topEdge.tscn").instance()
			else:
				print("main.gd: unhandled room type found: " + global.rooms[i].roomType)
			
			#put the x, y coords into the array data
			global.rooms[i].setX(roomX)
			global.rooms[i].setY(roomY)
			
			global.mainScreenTop = roomY

			roomScene.set_instance_data(global.rooms[i]) #put data from array into scene
			roomScene.set_position(Vector2(roomX,roomY))
			
			#print(global.rooms[i].roomType + " " + str(i) + " x:" + str(roomX) + " y:" + str(roomY))
			
			roomsLayer.add_child(roomScene)
				
			if (i == global.rooms.size() - 2): #if (i == global.rooms.size() - 2):
				roomY -= 224 #192 #224 #for placing the taller-than-a-room top edge piece
			else:
				roomY -= 192 #160
			
	#place the "add a room" button above the last placed piece
	$screen/button_addRoom.set_position(Vector2(150, roomY + 232))
	#display the cost to build a new room
	#print("main.gd: global.roomCount: " + str(global.roomCount))
	$screen/button_addRoom/field_addRoomButtonLabel.text = "BUILD A NEW ROOM \n" + str(global.newRoomCost[global.roomCount]) + " coins"

func _on_button_addRoom_pressed():
	get_tree().change_scene("res://menus/buildNewRoom.tscn")

#todo: this doesn't seem to be used, I had to implement it manually in load 
func save_global_vars():
	print("main.gd: saving these global vars")
	var save_dict = {
		"initDone":global.initDone,
        "guildName":global.guildName,
		"softCurrency":global.softCurrency,
		"hardCurrency":global.hardCurrency
		}
	return save_dict

func save_game():
	print("main.gd: using save_game() to write save file")
	var save_game = File.new()
	save_game.open("user://save_game.save", File.WRITE)
	
	#this is not the source of the twin heroes bug.... maybe
	#heroes and rooms are in Persist
	#maybe heroes are being saved twice and thus restored "twice"
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		var node_data = i.call("save") 
		save_game.store_line(to_json(node_data))
		
	#this is wrong because if we call save on just hero scenes
	# we miss all the heroes staffed to camps and harvest nodes 
	
	#this attempt at persisting globals doesn't cut it, either
	#they just get saved as strings like "[KinematicBody:123]"
	
	save_nodes = get_tree().get_nodes_in_group("PersistGlobals")
	for i in save_nodes:
		var node_data = i.call("save") 
		save_game.store_line(to_json(node_data))
		
	for hero in global.guildRoster:
		var node_data = hero.call("save")
		save_game.store_line(to_json(node_data))
	
	# save the vault contents
	var node_data = global.vault.save()
	save_game.store_line(to_json(node_data))
	
	save_game.close()
	
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://save_game.save"):
		print('ERROR! No save file exists!')
		return # Error! We don't have a save to load.
	
	#save_nodes is an array 
	#we had to separate "Persist" from "ClearOnRestore" so that heroes don't get saved twice
	var saved_nodes = get_tree().get_nodes_in_group("ClearOnRestore")
	for i in saved_nodes:
		i.queue_free()
		
	global.guildRoster.clear()
	global.unrecruited.clear()
	global.rooms.clear()
	
	#don't queue_free on PersistGlobals group 
	
	save_game.open("user://save_game.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if (current_line):
			
			#LOAD GLOBAL VARS
			print(current_line["filename"])
			if (current_line["filename"] == "res://global.gd"):
				var new_object = load(current_line["filename"])
				print("PROCESSING SAVED GLOBALS")
				
				#new way: manual 1:1 pairing
				#must match what's savde in global.gd's save_object
				global.softCurrency = current_line.softCurrency
				global.hardCurrency = current_line.hardCurrency
				global.guildName = current_line.guildName
				global.initDone = current_line.initDone
				global.nextHeroID = current_line.nextHeroID
				global.roomCount = current_line.roomCount
				global.tradeskills = current_line.tradeskills
				global.training = current_line.training
				global.testTimerBeginTime = current_line.testTimerBeginTime
				global.testTimerEndTime = current_line.testTimerEndTime
				global.activeHarvestingData = current_line.activeHarvestingData
				global.activeCampData = current_line.activeCampData
				global.vault = current_line.vault
				global.bedrooms = current_line.bedrooms
				
				#new_object gets printed as [GDScript:958] res://global.gd
				#parent is /root
				#print(new_object)
				#but for some reason, currencies are not restored (nor anything else in global)
				#get_node(current_line["parent"]).add_child(new_object) #current_line["parent"] is /root
			
			# LOAD GUILD VAULT (INVENTORY INSTANCE)
			if (current_line["filename"] == "inventoryFile"): #res://inventory.tscn
				var savedSize = current_line["inventory"].size()
				print("main.gd: restoring inventory of " + str(savedSize) + " items")
				
				# make a new inventory instance 
				var restored_vault = load("res://inventory.gd").new()
				
				# it's an array of items, so iterate through and rebuild a local copy
				for i in range(savedSize):
					var restored_item = current_line["inventory"][i]
					restored_vault._restore_from_save(restored_item)
				global.vault = restored_vault

			#LOAD HEROES
			#make this handle heroes specifically (to distinguish from other objects)
			if (current_line["filename"] == "heroFile"): #res://hero.tscn
				var restored_hero = load("res://hero.gd").new()
				
				#build the hero's params back in
				for key in current_line.keys():
					if (key == "filename" or key == "parent" or key == "savedPositionX" or key == "savedPositionY"):
						continue
					restored_hero.set(key, current_line[key])

				restored_hero.position = Vector2(current_line["savedPositionX"], current_line["savedPositionY"])
				
				if (restored_hero.recruited):
					global.guildRoster.append(restored_hero)
				elif (!restored_hero.recruited):
					global.unrecruited.append(restored_hero)
				else:
					print("main.gd: can't place this hero object")
				
			#LOAD ROOMS
			if (current_line["filename"] == "res://rooms/*.tscn"):
				var restored_room = load("res://rooms/room.gd").new()
				#print("PROCESSING SAVED ROOM SCENE")
				for key in current_line.keys():
					if (key == "filename" or key == "parent"):
						continue
					print("setting " + str(key) + " " + str(current_line[key]))
					restored_room.set(key, current_line[key])
				global.rooms.append(restored_room)
	save_game.close()
	
	#populate the "in progress" objects
	#had to do this down here because we need both heroes and tradeskills loaded first
	
	#this seems really cumbersome, is there some way to just ask each
	#tradeskill who belongs to it and hand over the correct hero instance?
					#empty out the campData arrays
	for key in global.activeCampData.keys():
		global.activeCampData[key].heroes = [] #.empty() leaves two kinematic bodies in the array
					
	for hero in global.guildRoster:
		#print(hero.get_first_name() + " is staffed to: " + str(hero.staffedTo) + " ID: " + str(hero.staffedToID))
		
		if (hero.staffedTo == "blacksmithing"):
			global.tradeskills["blacksmithing"].hero = hero
		elif (hero.staffedTo == "chronomancy"):
			global.tradeskills["chronomancy"].hero = hero
		elif (hero.staffedTo == "alchemy"):
			global.tradeskills["alchemy"].hero = hero
		elif (hero.staffedTo == "tailoring"):
			global.tradeskills["tailoring"].hero = hero
		elif (hero.staffedTo == "woodcraft"):
			global.tradeskills["woodcraft"].hero = hero
		elif (hero.staffedTo == "jewelcraft"):
			global.tradeskills["jewelcraft"].hero = hero
		elif (hero.staffedTo == "harvesting"):
			global.activeHarvestingData[hero.staffedToID].hero = hero
		elif (hero.staffedTo == "camp"):
			global.activeCampData[hero.staffedToID].heroes.append(hero)
		elif (hero.staffedTo == "training"):
			global.training[hero.staffedToID].hero = hero
	draw_heroes()
	draw_rooms()

func _on_button_saveGame_pressed():
	save_game()
	
func _on_button_loadGame_pressed():
	load_game()
	draw_HUD()


func _on_button_beginTimer_pressed():
	global.testTimerBeginTime = OS.get_unix_time() #seconds since epoch
	global.testTimerEndTime = OS.get_unix_time() + 60 #intended end time
	print("start time:" + str(global.testTimerBeginTime))
	print("end time: " + str(global.testTimerEndTime))
	pass # replace with function body


func _on_button_createHero_pressed():
	_save_hero_locations()
	global.currentMenu = "createHero"
	get_tree().change_scene("res://menus/createHero.tscn");
