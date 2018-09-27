extends Node

var heroGenerator = load("res://heroGenerator.gd").new()
var roomGenerator = load("res://roomGenerator.gd").new()

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

var questTimeLeft = -1

onready var roomsLayer = $screen/rooms

func _ready():
	global.currentMenu = "main"
	randomize()
	$HUD.update_currency(global.softCurrency, global.hardCurrency)
	
	# Generate default guildmembers and default rooms
	if (!global.initDone):
		heroGenerator.generate(global.guildRoster, "Wizard") #returns nothing, just puts them in the array reference that's passed in
		heroGenerator.generate(global.guildRoster, "Warrior")
		heroGenerator.generate(global.guildRoster, "Rogue")

		#Generate unrecruited heroes
		heroGenerator.generate(global.unrecruited, "Ranger")
		heroGenerator.generate(global.unrecruited, "Warrior")
	
		#generate rooms
		roomGenerator.generate("dummy") #placeholder for front yard (0)
		roomGenerator.generate("dummy") #placeholder for entrance hallway (1)
		roomGenerator.generate("bedroom")
		roomGenerator.generate("bedroom")
		roomGenerator.generate("blacksmith")
		roomGenerator.generate("vault")
		roomGenerator.generate("topEdge")
		global.initDone = true
	
	$HUD/vbox_currencies/HBoxContainer/field_guildCapacity.text = str(global.guildRoster.size()) + "/" + str(global.guildCapacity)
	
	$questMarker1._set_data("guild02")
	$questMarker2._set_data("guild04")
	
	draw_heroes()
	draw_rooms()
	
func _on_Quests_pressed():
	#global.currentMenu = "quests"
	#get_tree().change_scene("res://menus/questSelect.tscn");
	global.currentMenu = "quests"
	get_tree().change_scene("res://menus/maps/worldmap.tscn");

func _on_Vault_pressed():
	global.currentMenu = "vault"
	get_tree().change_scene("res://menus/vault.tscn");
	
func _on_Roster_pressed():
	global.currentMenu = "roster"
	get_tree().change_scene("res://menus/roster.tscn");
	
func _process(delta):
	#Displays how much time is left on the active quest 
	if (global.questActive && !global.questReadyToCollect):
		if (global.questTimer.time_left < 60):
			$HUD/button_collectQuest/field_questCountdown.set_text("< 1m")
			#$HUD/button_collectQuest/field_questCountdown.set_text(str(global.questTimer.time_left))
		else:
			$HUD/button_collectQuest/field_questCountdown.set_text("Long time")
	elif (!global.questActive && global.questReadyToCollect):
		$HUD/button_collectQuest/field_questCountdown.set_text("DONE!")
	else:
		$HUD/button_collectQuest/field_questCountdown.set_text("ERR!")
	
func draw_heroes():
	var heroX = -1
	var heroY = -1

	for i in range(global.guildRoster.size()):
		
		#only draw heroes who are "available" (ie: at home) 
		if (global.guildRoster[i].available):
			var heroScene = preload("res://hero.tscn").instance()
			heroScene.set_instance_data(global.guildRoster[i]) #put data from array into scene 
			heroScene._draw_sprites()
				
			if (global.guildRoster[i].currentRoom == 1):
				heroX = rand_range(mainRoomMinX, mainRoomMaxX)
				heroY = rand_range(mainRoomMinY, mainRoomMaxY)
				heroScene.set_position(Vector2(heroX, heroY))
			elif (global.guildRoster[i].currentRoom > 1):
				print("hero is in room " + str(global.guildRoster[i].currentRoom))
				heroScene.set_position(Vector2(global.rooms[global.guildRoster[i].currentRoom].roomX + 280, global.rooms[global.guildRoster[i].currentRoom].roomY + 20))
				
			add_child(heroScene)
	
	#draw unrecruited heroes outside the base
	for i in range(global.unrecruited.size()):
		heroX = rand_range(150, 380)
		heroY = rand_range(650, 820)
	
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_position(Vector2(heroX, heroY))
		heroScene.set_instance_data(global.unrecruited[i])
		heroScene._draw_sprites()
		add_child(heroScene)

func draw_rooms():
	#the room data is kept in global.rooms 
	#use that data to draw the instances into main.tscn 
	var roomX = -1
	var roomY = 75
	for i in range(global.rooms.size()):
		#rooms are different from heroes
		#heroes, all of them share one scene (hero.tscn)
		#rooms, they're all their own individual scenes
		#so we have to know what room we're making before we pick the correct scene
		var roomScene = null
		if (global.rooms[i].roomType == "dummy"):
			print("main.gd: skipping dummy room")
		else:
			if (global.rooms[i].roomType == "bedroom"):
				roomScene = preload("res://rooms/bedroom.tscn").instance()
			elif (global.rooms[i].roomType == "training"):
				roomScene = preload("res://rooms/training.tscn").instance()
			elif (global.rooms[i].roomType == "warrior"):
				roomScene = preload("res://rooms/warrior.tscn").instance()
			elif (global.rooms[i].roomType == "vault"):
				roomScene = preload("res://rooms/vault.tscn").instance()
			elif (global.rooms[i].roomType == "blacksmith"):
				roomScene = preload("res://rooms/blacksmith.tscn").instance()
			elif (global.rooms[i].roomType == "topEdge"):
				roomScene = preload("res://rooms/topEdge.tscn").instance()
			else:
				print("main.gd: unhandled room type found")
			
			#put the x, y coords into the array data
			global.rooms[i].setX(roomX)
			global.rooms[i].setY(roomY)
			
			roomScene.set_instance_data(global.rooms[i]) #put data from array into scene
			roomScene.set_position(Vector2(roomX,roomY))
			
			print(global.rooms[i].roomType + " " + str(i) + " x:" + str(roomX) + " y:" + str(roomY))
			
			roomsLayer.add_child(roomScene)
				
			if (i == global.rooms.size() - 2): #if (i == global.rooms.size() - 2):
				roomY -= 192 #for placing the taller-than-a-room top edge piece
				print("edge piece")
			else:
				roomY -= 128
				print("normal room")
			
	#place the "add a room" button above the last placed piece
	$screen/button_addRoom.set_position(Vector2(132, roomY + 200))
	#display the cost to build a new room
	$screen/button_addRoom/field_addRoomButtonLabel.text = "BUILD A NEW ROOM \n" + str(global.newRoomCost[global.roomCount]) + " coins"
func _on_button_addRoom_pressed():
	get_tree().change_scene("res://menus/buildNewRoom.tscn")


