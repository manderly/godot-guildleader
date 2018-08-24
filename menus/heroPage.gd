extends Node2D
#heroPage.gd 
func _ready():
	populate_fields(global.selectedHero)
	
	#for each inventory slot, create a heroPage_inventoryButton instance and place it in a row
	for i in range(global.heroInventorySlots.size()):
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
	if (data.recruited):
		$button_trainOrRecruit.text = "Train to next level"
	else:
		$button_trainOrRecruit.text = "Recruit hero"

func _on_button_train_pressed():
	if (global.selectedHero.recruited):
		if (global.selectedHero.xp == global.levelXpData[global.selectedHero.level].total):
			#todo: this should be on a timer and the hero is unavailable while training
			#also, only one hero can train up at a time 
			global.selectedHero.xp = 0
			global.selectedHero.level += 1
		else: 
			$confirm_instant_train.popup()
			
	else: #hero not part of guild yet
		#print("heroPage.gd: Recruiting this hero: " + global.selectedHero.heroName)
		#loop through unrecruited hero array and find the one that we're viewing
		for i in range(global.unrecruited.size()):
			if (global.unrecruited[i].heroID == global.selectedHero.heroID):
				#change recruited boolean to true and append to guildRoster
				global.unrecruited[i].recruited = true
				global.guildRoster.append(global.unrecruited[i])
				break
		
		#now remove this hero from the unrecruited hero array
		for i in range(global.unrecruited.size()):
			if (global.unrecruited[i].heroID == global.selectedHero.heroID):
				var findMe = global.selectedHero
				var index = global.unrecruited.find(findMe)
				global.unrecruited.remove(index)
				break
				
		#finally, go back to main 
		get_tree().change_scene("res://main.tscn")

func _on_button_rename_pressed():
	get_node("confirm_rename_dialog").popup()
	
func _on_button_dismiss_pressed():
	get_node("confirm_dismiss_dialog").popup()

func _on_rename_dialogue_confirmed():
	var newName = $confirm_rename_dialog/LineEdit.text
	print("heropage.gd: Renamed hero to: " + newName)
	global.selectedHero.heroName = newName
	#redraw the name display field on the hero page with the new name
	$field_heroName.text = global.selectedHero.heroName
	
func _on_button_back_pressed():
	if (global.currentMenu == "roster"):
		get_tree().change_scene("res://menus/roster.tscn")
	elif (global.currentMenu == "quests"):
		get_tree().change_scene("res://menus/questConfirm.tscn")
	else:
		get_tree().change_scene("res://main.tscn")

func _on_confirm_dismiss_dialog_confirmed():
	#Remove this hero from the guild
	#Return to main screen
	#print("looking for: " + global.selectedHero.heroName)
	for i in range(global.guildRoster.size()):
		#print (str(i) + " of " + str(global.guildRoster.size()))
		if (global.guildRoster[i].heroID == global.selectedHero.heroID):
			var findMe = global.selectedHero
			var removeIndex = global.guildRoster.find(findMe)
			global.guildRoster.remove(removeIndex)
			get_tree().change_scene("res://main.tscn")
			break

func _on_confirm_instant_train_confirmed():
	if (global.hardCurrency >= 1):
		print("Training this hero to next level")
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time
		global.hardCurrency -= 1
		global.selectedHero.xp = 0
		global.selectedHero.level += 1
		#todo: refactor the redrawing of fields into something less case-by-case
		$field_levelAndClass.text = str(global.selectedHero.level) + " " + global.selectedHero.heroClass
	else: 
		print("heroPage.gd: not enough diamonds")
