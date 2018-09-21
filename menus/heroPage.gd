extends Node2D
#heroPage.gd

var heroEquipmentSlots = ["mainHand", "offHand", "jewelry", "unknown", "head", "chest", "legs", "feet"]
var heroEquipmentSlotNames = ["Main", "Offhand", "Jewelry", "???", "Head", "Chest", "Legs", "Feet"]

var displayHP = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayMana = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayArmor = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayDPS = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySTA = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayDEF = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayINT = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayDrama = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayMood = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayPrestige = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayGroupBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayRaidBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
	
func _ready():
	#hide dismiss and rename buttons if this hero isn't a recruited hero
	if (!global.selectedHero.recruited):
		$button_rename.hide()
		$button_dismiss.hide()
	
	#for each inventory slot, create a heroPage_inventoryButton instance and place it in a row
	#todo: this might be able to share logic with vault_itemButton.gd or combine with it 
	#print(global.selectedHero["equipment"]["mainHand"])
	
	#Create the inventory (equipment) buttons 
	var slot = null
	for i in range(heroEquipmentSlots.size()):
		slot = heroEquipmentSlots[i]
		
		var heroInventoryButton = preload("res://menus/itemButton.tscn").instance()
		heroInventoryButton._set_label(heroEquipmentSlotNames[i])
		heroInventoryButton._set_slot(heroEquipmentSlotNames[i])
		heroInventoryButton.connect("updateStatsOnHeroPage", self, "_update_stats") #_update_stats
		
		#only set icon if the hero actually has an item in this slot, otherwise empty
		#this looks in the selected hero's equipment object for something called "mainHand" or "offHand" etc 
		
			
		if (global.selectedHero["equipment"][slot] != null):
			#global.logger(self, "this hero has an item in their slot: " + slot)
			#global.logger(self, global.selectedHero["equipment"][slot])
			heroInventoryButton._set_icon(global.selectedHero["equipment"][slot]["icon"]) #put item's icon on button 
			heroInventoryButton._set_data(global.selectedHero["equipment"][slot])
	
		$centerContainer/grid.add_child(heroInventoryButton)
		
	#for each stat, place its instance into the appropriate vbox
	#populating the data is done in a separate method, update_stats 
	#LEFT SIDE
	$vbox_stats1.add_child(displayHP)
	$vbox_stats1.add_child(displayMana)
	$vbox_stats1.add_child(displayArmor)
	$vbox_stats1.add_child(displayDPS)
	$vbox_stats1.add_child(displaySTA)
	$vbox_stats1.add_child(displayDEF)
	$vbox_stats1.add_child(displayINT)

	#RIGHT SIDE
	$vbox_stats2.add_child(displayDrama)
	$vbox_stats2.add_child(displayMood)
	$vbox_stats2.add_child(displayPrestige)
	$vbox_stats2.add_child(displayGroupBonus)
	$vbox_stats2.add_child(displayRaidBonus)
	populate_fields(global.selectedHero)
	
func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = str(data.level) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.xp) + "/" + str(global.levelXpData[data.level].total)
	if (data.recruited):
		$button_trainOrRecruit.text = "Train to next level"
	else:
		$button_trainOrRecruit.text = "Recruit hero"
	_update_stats()
	
func _update_stats():
	displayHP._update_fields("HP", global.selectedHero.hp)
	if (global.selectedHero.heroClass != "Warrior" && global.selectedHero.heroClass != "Rogue"):
		displayMana._update_fields("Mana", global.selectedHero.mana)
	else:
		displayMana.hide()
	displayArmor._update_fields("Armor", global.selectedHero.armor)
	displayDPS._update_fields("DPS", global.selectedHero.dps)
	displaySTA._update_fields("STA", global.selectedHero.stamina)
	displayDEF._update_fields("DEF", global.selectedHero.defense)	
	displayINT._update_fields("INT", global.selectedHero.intelligence)
	displayDrama._update_fields("Drama", global.selectedHero.drama)
	displayMood._update_fields("Mood", global.selectedHero.mood)
	displayPrestige._update_fields("Prestige", global.selectedHero.prestige)
	displayGroupBonus._update_fields("Group Bonus", global.selectedHero.groupBonus)
	displayRaidBonus._update_fields("Raid Bonus", global.selectedHero.raidBonus)
	
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
		
		#first, see if we have space for this hero
		if (global.guildRoster.size() == global.guildCapacity):
			print("not enough room!")
			get_node("insufficient_guild_capacity_dialog").popup()
		elif (global.guildRoster.size() < global.guildCapacity):
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
				
			#after successful recruit, go back to main 
			#todo: maybe stay on hero page? might be more intuitive 
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
		$field_xp.text = "XP: " + str(global.selectedHero.xp) + "/" + str(global.levelXpData[global.selectedHero.level].total)
		$field_levelAndClass.text = str(global.selectedHero.level) + " " + global.selectedHero.heroClass
	else: 
		print("heroPage.gd: not enough diamonds")

#make the entire vbox clickable
func _on_vbox_stats1_gui_input(ev):
	if ev is InputEventMouseButton \
    and ev.button_index == BUTTON_LEFT \
    and ev.is_pressed():
		get_node("info_statsLeft_dialog").popup()
	
#make the entire vbox clickable
func _on_vbox_stats2_gui_input(ev):
	if ev is InputEventMouseButton \
    and ev.button_index == BUTTON_LEFT \
    and ev.is_pressed():
		get_node("info_statsRight_dialog").popup()
	
