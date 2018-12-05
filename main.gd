extends Node
#main.gd

var heroGenerator = load("res://heroGenerator.gd").new()
var roomGenerator = load("res://roomGenerator.gd").new()

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

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
		"y":380
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

var questTimeLeft = -1

onready var roomsLayer = $screen/rooms

var onscreenHeroes = []

func _ready():
	randomize()
	global.currentMenu = "main"
	
	#load_game()

	$HUD.update_currency(global.softCurrency, global.hardCurrency)

	# Generate default guildmembers and default rooms
	if (global.initDone == false):
		
		var global_vars = get_node("/root/global")
		global_vars.add_to_group("PersistGlobals")
	
		heroGenerator.generate(global.guildRoster, "Wizard") #returns nothing, just puts them in the array reference that's passed in
		heroGenerator.generate(global.guildRoster, "Warrior")
		heroGenerator.generate(global.guildRoster, "Rogue")
		#Generate a few more guildmates for quest testing
		#heroGenerator.generate(global.guildRoster, "Wizard") #returns nothing, just puts them in the array reference that's passed in
		heroGenerator.generate(global.guildRoster, "Ranger")
		#heroGenerator.generate(global.guildRoster, "Cleric")
		
		#Generate unrecruited heroes
		#heroGenerator.generate(global.unrecruited, "Cleric")
		#heroGenerator.generate(global.unrecruited, "Rogue")
		heroGenerator.generate(global.unrecruited, "Ranger")
		heroGenerator.generate(global.unrecruited, "Druid")
		#heroGenerator.generate(global.unrecruited, "Warrior")
		
		#generate starting rooms
		roomGenerator.generate("dummy", false) #placeholder for front yard (0)
		roomGenerator.generate("dummy", false) #placeholder for entrance hallway (1)
		roomGenerator.generate("blacksmith", false)
		roomGenerator.generate("tailoring", false)
		roomGenerator.generate("bedroom", false)
		roomGenerator.generate("bedroom", false)
		roomGenerator.generate("vault", false)
		roomGenerator.generate("topEdge", false)
		
		util.give_quest("test09")
		util.give_quest("test10")
		util.give_quest("azuricite_quest01")
		global.selectedQuestID = "test09"
	
		global.initDone = true

	else:
		print("loaded game")
	
	#restore saved camera position
	$screen/mainCamera.set_position()
		
	$HUD/hbox/field_guildCapacity.text = str(global.guildRoster.size()) + "/" + str(global.guildCapacity)
	draw_heroes()
	draw_rooms()
	
func _save_hero_locations():
	#save the x and y of every hero currently on the screen
	for hero in onscreenHeroes:
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
	pass
	
func draw_heroes():
	var heroX = -1
	var heroY = -1
	onscreenHeroes = []
	
	for i in range(global.guildRoster.size()):
		#draw heroes who are "atHome"
		if (global.guildRoster[i].atHome && global.guildRoster[i].staffedTo == ""):
			#we only need to make a new instance if this hero
			#is "wandering" the guildhall
			var heroScene = load("res://hero.tscn").instance()
			heroScene.set_instance_data(global.guildRoster[i]) #put data from array into scene 
			heroScene._draw_sprites()
			#print(global.guildRoster[i].heroName + " wants to be at " + str(global.guildRoster[i].savedPosition))
			if (global.guildRoster[i].savedPositionX == -1):
				heroX = spawnLocs[str(i)]["x"]
				heroY = spawnLocs[str(i)]["y"]
			else:
				heroX = global.guildRoster[i].savedPositionX #rand_range(mainRoomMinX, mainRoomMaxX)
				heroY = global.guildRoster[i].savedPositionY #rand_range(mainRoomMinY, mainRoomMaxY)
			
			heroScene.set_position(Vector2(heroX, heroY))
			heroScene.set_display_params(true, true) #walking, show name
			onscreenHeroes.append(heroScene)
			add_child(heroScene)
			
	#draw unrecruited heroes outside the base
	for i in range(global.unrecruited.size()):
		if (global.unrecruited[i].savedPositionX == -1):
			heroX = rand_range(150, 380)
			heroY = rand_range(650, 820)
		else:
			heroX = global.unrecruited[i].savedPositionX #rand_range(150, 380)
			heroY = global.unrecruited[i].savedPositionY #rand_range(650, 820)
			
		var heroScene = load("res://hero.tscn").instance()
		heroScene.set_position(Vector2(heroX, heroY))
		heroScene.set_instance_data(global.unrecruited[i])
		heroScene._draw_sprites()
		heroScene.set_display_params(true, true) #walking, show name
		onscreenHeroes.append(heroScene)
		add_child(heroScene)

func draw_rooms():
	#the room data is kept in global.rooms 
	#use that data to draw the instances into main.tscn 
	var roomX = -1
	var roomY = 43
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
			elif (global.rooms[i].roomType == "tailoring"):
				roomScene = load("res://rooms/tailoring.tscn").instance()
			elif (global.rooms[i].roomType == "jewelcraft"):
				roomScene = load("res://rooms/jewelcraft.tscn").instance()
			elif (global.rooms[i].roomType == "fletching"):
				roomScene = load("res://rooms/fletching.tscn").instance()
			elif (global.rooms[i].roomType == "topEdge"):
				roomScene = load("res://rooms/topEdge.tscn").instance()
			else:
				print("main.gd: unhandled room type found: " + global.rooms[i].roomType)
			
			#put the x, y coords into the array data
			global.rooms[i].setX(roomX)
			global.rooms[i].setY(roomY)
			
			roomScene.set_instance_data(global.rooms[i]) #put data from array into scene
			roomScene.set_position(Vector2(roomX,roomY))
			
			#print(global.rooms[i].roomType + " " + str(i) + " x:" + str(roomX) + " y:" + str(roomY))
			
			roomsLayer.add_child(roomScene)
				
			if (i == global.rooms.size() - 2): #if (i == global.rooms.size() - 2):
				roomY -= 192 #for placing the taller-than-a-room top edge piece
			else:
				roomY -= 160
			
	#place the "add a room" button above the last placed piece
	$screen/button_addRoom.set_position(Vector2(132, roomY + 200))
	#display the cost to build a new room
	#print("main.gd: global.roomCount: " + str(global.roomCount))
	$screen/button_addRoom/field_addRoomButtonLabel.text = "BUILD A NEW ROOM \n" + str(global.newRoomCost[global.roomCount]) + " coins"

func _on_button_addRoom_pressed():
	get_tree().change_scene("res://menus/buildNewRoom.tscn")

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
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		var node_data = i.call("save") 
		save_game.store_line(to_json(node_data))
	save_game.close()
	
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://save_game.save"):
		print('ERROR! No save file exists!')
		return # Error! We don't have a save to load.
	
	#save_nodes is an array 
	var saved_nodes = get_tree().get_nodes_in_group("Persist")
	for i in saved_nodes:
		i.queue_free()

		
	#clear it out so we don't get dupes
	global.guildRoster = []
	global.unrecruited = []
	global.rooms = []
	
	#don't queue_free on PersistGlobals group 
	
	save_game.open("user://save_game.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if (current_line):
			
			#LOAD HEROES
			#make this handle heroes specifically (to distinguish from other objects)
			if (current_line["filename"] == "res://hero.tscn"):
				var restored_hero = load("res://hero.gd").new()
				#var restored_hero = load(current_line["filename"]).instance()
				
				#build the hero's params back in
				for key in current_line.keys():
					if (key == "filename" or key == "parent" or key == "savedPositionX" or key == "savedPositionY"):
						continue
					restored_hero.set(key, current_line[key])
				
				#position this hero (or at least load it with coordinates)
				restored_hero.position = Vector2(current_line["savedPositionX"], current_line["savedPositionY"])
				
				#append it into the correct array 
				if (restored_hero.recruited):
					global.guildRoster.append(restored_hero)
				elif (!restored_hero.recruited):
					global.unrecruited.append(restored_hero)
				else:
					print("main.gd: can't place this object")
			
			#LOAD GLOBAL VARS
			if (current_line["filename"] == "res://global.gd"):
				var new_object = load(current_line["filename"])
				print("PROCESSING SAVED GLOBALS")
				#build the hero's params back in
				for key in current_line.keys():
					if (key == "filename" or key == "parent"):
						continue
					new_object.set(key, current_line[key])
				#new_object.rooms = []
				new_object.guildRoster = [] #egads, this seems dangerous!
				new_object.unrecruited = [] #egads, this too
				get_node(current_line["parent"]).add_child(new_object)
				
			#LOAD ROOMS	?
			if (current_line["filename"] == "res://rooms/*.tscn"):
				var restored_room = load("res://rooms/room.gd").new()
				#print("PROCESSING SAVED ROOM SCENE")
				for key in current_line.keys():
					if (key == "filename" or key == "parent"):
						continue
					#print("setting " + str(key) + " " + str(current_line[key]))
					restored_room.set(key, current_line[key])
				global.rooms.append(restored_room)
	save_game.close()
	
	#populate tradeskills object
	#had to do this down here because we need both heroes and tradeskills loaded
	#to do this operation
	
	#this seems really cumbersome, is there some way to just ask each
	#tradeskill who belongs to it and hand over the correct hero instance?
	for hero in global.guildRoster:
		print(hero.heroName + " is staffed to: " + hero.staffedTo)
		if (hero.staffedTo == "blacksmithing"):
			global.tradeskills["blacksmithing"].hero = hero
		elif (hero.staffedTo == "alchemy"):
			global.tradeskills["alchemy"].hero = hero
		elif (hero.staffedTo == "tailoring"):
			global.tradeskills["tailoring"].hero = hero
		elif (hero.staffedTo == "fletching"):
			global.tradeskills["fletching"].hero = hero
		elif (hero.staffedTo == "jewelcraft"):
			global.tradeskills["jewelcraft"].hero = hero	
	draw_heroes()
	draw_rooms()

func _on_button_saveGame_pressed():
	save_game()
	
func _on_button_loadGame_pressed():
	load_game()
