extends Node

var nameGenerator = load("res://nameGenerator.gd").new()

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

func _ready():
	global.currentMenu = "main"
	randomize()
	$HUD.update_currency(global.softCurrency, global.hardCurrency)
	
	var roomsLayer = $screen/rooms 
	#spawn the player's rooms (use roomOrder array)
	var roomX = -1
	var roomY = 75 
	for i in range(global.roomOrder.size()):
		var roomInstance = global.roomOrder[i].instance()
		roomInstance.set_position(Vector2(roomX,roomY))
		roomInstance.display_room_name("coded name")
		roomsLayer.add_child(roomInstance)
		if (i == global.roomOrder.size() - 2):
			roomY -= 192 #for placing the taller-than-a-room top edge piece
		else:
			roomY -= 128
			
	#place the "add a room" button above the last placed piece
	$screen/button_addRoom.set_position(Vector2(132, roomY + 200))
	#display the cost to build a new room
	$screen/button_addRoom.text = "BUILD A NEW ROOM: " + str(global.newRoomCost[global.roomCount]) + " coins"
	
	# Generate X number of heroes (default guild members for now)
	if (!global.initDone):
		var heroQuantity = 3

		for i in range(heroQuantity):
			#make new hero object
			var newHero = {}
			
			#random name
			newHero.heroName = nameGenerator.generate(3, 6) + " " + nameGenerator.generate(3, 9)
			
			#random class
			var randomNumber = randi()%3+1
			if randomNumber == 1:
				newHero.heroClass = "Wizard"
			elif randomNumber == 2:
				newHero.heroClass = "Rogue"
			else:
				newHero.heroClass = "Warrior"
	
			#assign stats accordingly
			newHero.hp = global.heroStartingStatData[newHero.heroClass]["hp"]
			newHero.mana = global.heroStartingStatData[newHero.heroClass]["mana"]
			newHero.dps = global.heroStartingStatData[newHero.heroClass]["dps"]
			newHero.stamina = global.heroStartingStatData[newHero.heroClass]["stamina"]
			newHero.defense = global.heroStartingStatData[newHero.heroClass]["defense"]
			newHero.intelligence = global.heroStartingStatData[newHero.heroClass]["intelligence"]
			newHero.drama = global.heroStartingStatData[newHero.heroClass]["drama"]
			newHero.mood = global.heroStartingStatData[newHero.heroClass]["mood"]
			newHero.prestige = global.heroStartingStatData[newHero.heroClass]["prestige"]
			newHero.groupBonus = global.heroStartingStatData[newHero.heroClass]["groupBonus"]
			newHero.raidBonus = global.heroStartingStatData[newHero.heroClass]["raidBonus"]

			newHero.level = 1
			newHero.xp = 0
			newHero.currentRoom = 1
			newHero.available = true
		
			global.guildRoster.append(newHero)
			
		#verify they were generated 
		print("Guild members are:")
		for i in range(heroQuantity):
			print(global.guildRoster[i].heroName)

		global.initDone = true
		
		#use the hero data to create individual hero scene instances
		draw_heroes()
	else:
		#use the hero data to create individual hero scene instances
		draw_heroes()

func _on_Quests_pressed():
	global.currentMenu = "quests"
	get_tree().change_scene("res://menus/questSelect.tscn");
	
func _on_Roster_pressed():
	global.currentMenu = "roster"
	get_tree().change_scene("res://menus/roster.tscn");

func draw_heroes():
	var heroX = -1
	var heroY = -1

	for i in range(global.guildRoster.size()):
		heroX = rand_range(mainRoomMinX, mainRoomMaxX)
		heroY = rand_range(mainRoomMinY, mainRoomMaxY)
	
		#only draw heroes who are "available" (ie: at home) 
		if (global.guildRoster[i].available):
			var heroScene = preload("res://hero.tscn").instance()
			heroScene.set_position(Vector2(heroX, heroY))
			heroScene.set_display_fields(global.guildRoster[i])
			add_child(heroScene)

func _on_button_collectQuest_pressed():
	pass


func _on_button_addRoom_pressed():
	get_tree().change_scene("res://menus/buildNewRoom.tscn")
