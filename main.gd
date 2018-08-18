extends Node

var nameGenerator = load("res://nameGenerator.gd").new()
	
func _ready():
	global.currentMenu = "main"
	randomize()
	$HUD.update_currency(global.softCurrency, global.hardCurrency)
		
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
	
func _on_Hero_pressed():
	global.currentMenu = "heroPage"
	get_tree().change_scene("res://menus/heroPage.tscn");

func draw_heroes():
	var heroX = 100
	var heroY = 100
	
	for i in range(global.guildRoster.size()):
		#only draw heroes who are "available" (ie: at home) 
		if (global.guildRoster[i].available):
			var heroScene = preload("res://hero.tscn").instance()
			heroScene.set_position(Vector2(heroX, heroY))
			heroScene.set_display_fields(global.guildRoster[i])
			add_child(heroScene)
			heroX += 20
			heroY += 100



