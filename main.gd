extends Node

var nameGenerator = load("res://nameGenerator.gd").new()
	
func _ready():
	randomize()
	# these should be global variables
	$HUD.update_currency(150, 15)
		
	# Generate X number of heroes (default guild members for now)
	if (!playervars.initDone):
		var heroQuantity = 3

		for i in range(heroQuantity):
			#make a name
			var newHeroFirstName = nameGenerator.generate(3, 6)
			var newHeroLastName = nameGenerator.generate(3, 9)
			var newHeroFullName = newHeroFirstName + " " + newHeroLastName
			
			#pick a random class
			var newHeroClass = "NONE"
			var randomNumber = randi()%3+1
			
			if randomNumber == 1:
				newHeroClass = "Wizard"
			elif randomNumber == 2:
				newHeroClass = "Rogue"
			else:
				newHeroClass = "Warrior"
			
			#new hero object
			var newHero = {}
		
			newHero.heroName = newHeroFullName
			newHero.heroLevel = 1
			newHero.heroXp = 0
			newHero.heroHp = 10
			newHero.heroClass = newHeroClass
			newHero.currentRoom = 1
			newHero.available = true
		
			playervars.guildRoster.append(newHero)
			
		#verify they were generated 
		print("Guild members are:")
		for i in range(heroQuantity):
			print(playervars.guildRoster[i].heroName)

		playervars.initDone = true
		
		#use the hero data to create individual hero scene instances
		draw_heroes()
	else:
		#use the hero data to create individual hero scene instances
		draw_heroes()

func _on_Quests_pressed():
	get_tree().change_scene("res://menus/questSelect.tscn");

func draw_heroes():
	var heroX = 100
	var heroY = 100
	
	for i in range(playervars.guildRoster.size()):
		var heroScene = preload("res://hero.tscn").instance()
		heroScene.set_position(Vector2(heroX, heroY))
		heroScene.set_display_fields(playervars.guildRoster[i])
		add_child(heroScene)
		heroX += 20
		heroY += 100
