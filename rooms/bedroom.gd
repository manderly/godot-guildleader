extends "room.gd"
#bedroom.gd
#inherits all of room's methods 

onready var field_occupancy = $field_occupancy

# must exist in each scene that renders heroes
onready var heroesNode = $YSort

func _ready():
	var occupied = 0
	for i in global.bedrooms[roomID].size():
		# look for occupied "slots" in this bedroom;s array 
		if global.bedrooms[roomID][i] > 0:
			occupied+=1
			
	set_occupancy(occupied)
	draw_hero_and_button()

func draw_hero_and_button():
	# a hero who is "staffed" to his bedroom will appear in his bedroom
	for i in (global.bedrooms[roomID].size()): # account for index 0 and index 1
		if (global.bedrooms[roomID][i] > 0):
			# get hero's data from global array using this ID
			var hero = util.get_hero_by_id(global.bedrooms[roomID][i])
			# get the hero by this ID 
			if (hero.idleIn == "bedroom"):
				var heroScene = preload("res://baseEntity.tscn").instance()
				heroScene.set_script(preload("res://hero.gd"))
				heroScene.set_instance_data(hero) #put data from array into scene 
				heroScene._draw_sprites()
				# set position 
				# if hero has no saved position, spawn at default bedroom location 
				if (hero.savedPositionX == -1):
					if (i == 0):
						heroScene.set_position(Vector2(280, 40))
					elif (i == 1):
						heroScene.set_position(Vector2(220, 90))
					
				else:
					var heroX = hero.savedPositionX 
					var heroY = hero.savedPositionY
					var facing = hero.savedFacing 
					heroScene.set_position(Vector2(heroX, heroY))
					#print("Restoring " + hero.get_first_name() + "'s facing: " + global.guildRoster[i].savedFacing)
					if (hero.savedFacing == "left"):
						heroScene.face_left()
					elif (hero.savedFacing == "right"):
						heroScene.face_right()
				
				heroScene.set_display_params(true, true) #walking, show name
				
				global.onscreenHeroes.append(heroScene)
				heroesNode.add_child(heroScene)
				add_child(heroScene)
	
func set_occupancy(occupancy):
	field_occupancy.text = str(occupancy)+"/"+str(global.bedroomMaxOccupancy)