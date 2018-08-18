extends Node2D

func _ready():
	populate_fields(global.selectedHero)
	
	#for each inventory slot, create a heroPage_inventoryButton instance and place it in a row
	for i in range(global.heroInventorySlots.size()):
		print(global.heroInventorySlots[i])
		var heroInventoryButton = preload("res://menus/heroPage_inventoryButton.tscn").instance()
		heroInventoryButton.set_label(global.heroInventorySlots[i])
		#heroInventoryButton.set_position(Vector2(buttonX, buttonY))
		if (i < 4):
			$hbox_items.add_child(heroInventoryButton)
		else:
			$hbox_items2.add_child(heroInventoryButton)
		#todo: later, expand this to show the actual item owned by this hero for this slot 
		
	#for each stat, make an instance and pass the data into it 
	#LEFT SIDE
	var displayHP = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayHP._update_fields("HP", global.selectedHero.hp)
	$vbox_stats1.add_child(displayHP)
	
	var displayMana = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayMana._update_fields("Mana", global.selectedHero.mana)
	$vbox_stats1.add_child(displayMana)
	
	var displayDPS = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayDPS._update_fields("DPS", global.selectedHero.dps)
	$vbox_stats1.add_child(displayDPS)
	
	var displaySTA = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displaySTA._update_fields("STA", global.selectedHero.stamina)
	$vbox_stats1.add_child(displaySTA)
	
	var displayDEF = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayDEF._update_fields("DEF", global.selectedHero.defense)
	$vbox_stats1.add_child(displayDEF)
	
	var displayINT = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayINT._update_fields("INT", global.selectedHero.intelligence)
	$vbox_stats1.add_child(displayINT)

	#RIGHT SIDE
	var displayDrama = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayDrama._update_fields("Drama", global.selectedHero.drama)
	$vbox_stats2.add_child(displayDrama)
	
	var displayMood = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayMood._update_fields("Mood", global.selectedHero.mood)
	$vbox_stats2.add_child(displayMood)
	
	var displayPrestige = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayPrestige._update_fields("Prestige", global.selectedHero.prestige)
	$vbox_stats2.add_child(displayPrestige)
	
	var displayGroupBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayGroupBonus._update_fields("Group Bonus", global.selectedHero.groupBonus)
	$vbox_stats2.add_child(displayGroupBonus)
	
	var displayRaidBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	displayRaidBonus._update_fields("Raid Bonus", global.selectedHero.raidBonus)
	$vbox_stats2.add_child(displayRaidBonus)
	
func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = str(data.level) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.xp) + "/" + str(global.levelXpData[data.level].total)

func _on_button_train_pressed():
	if (global.selectedHero.xp == global.levelXpData[global.selectedHero.level].total):
		print("Training this hero to next level")
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time 
		global.selectedHero.xp = 0
		global.selectedHero.level += 1
	else: 
		print("Need more xp - or pay diamonds to level up now!")


func _on_button_back_pressed():
	get_tree().change_scene("res://menus/roster.tscn")
