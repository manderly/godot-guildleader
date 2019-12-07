extends Node2D
#heroPage.gd

var heroEquipmentSlots = ["mainHand", "offHand", "jewelry", "unknown", "head", "chest", "legs", "feet"]
var heroEquipmentSlotNames = ["Main", "Secondary", "Jewelry", "???", "Head", "Chest", "Legs", "Feet"]

onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()

#Stats
var displayHP = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayMana = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayArmor = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayDPS = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySTR = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayDEF = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayINT = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()

var displayHPRegen = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayManaRegen = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()

var displayCritChance = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()

#Skills
var displaySkillAlchemy = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillBlacksmithing = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillChronomancy = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillFletching = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillJewelcraft = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillTailoring = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displaySkillHarvesting = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()

#Attributes
var displayDrama = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayMood = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayPrestige = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayGroupBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()
var displayRaidBonus = preload("res://menus/heroPage_heroStatDisplay.tscn").instance()

#fields (labels)
onready var label_heroName = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/field_heroName
onready var label_levelAndClass = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/field_levelAndClass
onready var label_xp = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/field_xp
onready var progressBar = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/progress_xp

onready var buttonTrainOrRecruit = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/button_trainOrRecruit
onready var buttonRevive = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Right/button_revive
onready var buttonDismiss = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Right/button_dismiss
onready var buttonRename = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Right/button_rename
onready var buttonRenameFirst = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Right/button_renameFirst
onready var buttonShowHelm = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Right/button_helm

#containers
onready var inventoryGrid = $CenterContainer/VBoxContainer/centerContainer/grid

onready var tabStatsLeft = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Stats/StatsLeft
onready var tabStatsRight = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Stats/StatsRight
onready var tabSkills = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Skills
onready var tabAttributes = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Bonuses

onready var field_perkPoints = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Perks/VBoxContainer3/HBoxContainer/VBox_right/field_perkPoints
onready var tabPerksButtonsContainer = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Perks/VBoxContainer3/HBoxContainer/VBox_left
onready var field_perkDescription = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Perks/VBoxContainer3/HBoxContainer/VBox_right/field_perkDescription
onready var button_buyPerk = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Perks/VBoxContainer3/HBoxContainer/VBox_right/button_buyPerk
onready var button_refundPerks = $CenterContainer/VBoxContainer/CenterContainer/TabContainer/Perks/VBoxContainer3/HBoxContainer/VBox_right/button_refundPerks

var trainingData = null
var perkOnDeckKey = null

func _ready():
	
	$confirm_rename_dialog.set_mode("last")
	$confirm_rename_dialog.connect("heroNameUpdated", self, "populate_fields")
	$confirm_rename_dialog/LineEdit.connect("text_changed", self, "check_name_input") #, ["userInput"]
	
	#draw the hero
	var heroScene = preload("res://baseEntity.tscn").instance()
	heroScene.set_script(preload("res://hero.gd"))
	heroScene.set_instance_data(global.selectedHero) #put data from array into scene 
	heroScene._draw_sprites()
	heroScene.set_position(Vector2(50, 20))
	heroScene.set_display_params(false, false) #walking, show name
	heroScene.add_to_group("heroScene")
	add_child(heroScene)
	
	# tint the hero purple if dead
	if (global.selectedHero.dead):
		heroScene.modulate = Color(0.8, 0.7, 1)
	
	add_child(finishNowPopup)
	
	#check if training was in-progress if so, if it is now complete
	if (global.selectedHero.staffedTo == "training"):
		trainingData = global.training[global.selectedHero.staffedToID] #get the matching training room data
		
		if (OS.get_unix_time() >= trainingData.endTime):
			trainingData.readyToCollect = true

				
	#for each inventory slot, create a heroPage_inventoryButton instance and place it in a row
	#todo: this might be able to share logic with vault_itemButton.gd or combine with it 
	#print(global.selectedHero["equipment"]["mainHand"])
	
	if (global.selectedHero.charClass == "Ranger"):
		heroEquipmentSlotNames[0] = "Bow"
		heroEquipmentSlotNames[1] = "Arrow"
	
	#Create the inventory (equipment) buttons 
	var slot = null
	for i in range(heroEquipmentSlots.size()):
		slot = heroEquipmentSlots[i]
		
		var heroInventoryButton = preload("res://menus/itemButton.tscn").instance()
		heroInventoryButton._set_label(heroEquipmentSlotNames[i])
		heroInventoryButton._set_slot(heroEquipmentSlots[i])
		heroInventoryButton.add_to_group("InventoryButtons")
		
		if (global.selectedHero && !global.selectedHero.recruited):
			#don't show move to vault or trash buttons if this hero isn't recruited
			heroInventoryButton._set_info_popup_buttons(false, false, "none")
		else:
			#show buttons and give the option to put item in vault if hero is recruited
			heroInventoryButton._set_info_popup_buttons(true, true, "Put in vault")
			if (global.selectedHero.dead):
				heroInventoryButton.set_disabled(true)
			
		heroInventoryButton.connect("updateStatsOnHeroPage", self, "_update_stats") #_update_stats
		#only set icon if the hero actually has an item in this slot, otherwise empty
		#this looks in the selected hero's equipment object for something called "mainHand" or "offHand" etc 
		if (global.selectedHero["equipment"][slot] != null):
			#global.logger(self, "this hero has an item in their slot: " + slot)
			#global.logger(self, global.selectedHero["equipment"][slot])
			heroInventoryButton._render_hero_page(global.selectedHero["equipment"][slot])
	
		inventoryGrid.add_child(heroInventoryButton)
		
	#for each stat, place its instance into the appropriate vbox
	#populating the data is done in a separate method, update_stats 
	
	#Stats
	tabStatsLeft.add_child(displayHP)
	tabStatsLeft.add_child(displayMana)
	tabStatsLeft.add_child(displayArmor)
	tabStatsLeft.add_child(displayDPS)
	tabStatsLeft.add_child(displaySTR)
	tabStatsLeft.add_child(displayDEF)
	tabStatsLeft.add_child(displayINT)
	
	tabStatsRight.add_child(displayHPRegen)
	tabStatsRight.add_child(displayManaRegen)
	
	tabStatsRight.add_child(displayCritChance)
	
	#Skills
	tabSkills.add_child(displaySkillAlchemy)
	tabSkills.add_child(displaySkillBlacksmithing)
	tabSkills.add_child(displaySkillChronomancy)
	tabSkills.add_child(displaySkillFletching)
	tabSkills.add_child(displaySkillJewelcraft)
	tabSkills.add_child(displaySkillTailoring)
	tabSkills.add_child(displaySkillHarvesting)

	#Attributes
	tabAttributes.add_child(displayDrama)
	tabAttributes.add_child(displayMood)
	tabAttributes.add_child(displayPrestige)
	tabAttributes.add_child(displayGroupBonus)
	tabAttributes.add_child(displayRaidBonus)
	
	#select the first perk by default (select by key)	
	var perkKeys = global.selectedHero.perks.keys() #an array of perk names
	_select_perk(perkKeys[0])
	
	#fill perks tab with buttons
	for key in global.selectedHero.perks.keys():
		var perk = global.selectedHero.perks[key]
		var perkButton = Button.new()
		perkButton.text = perk.perkName + " " + str(perk.pointsSpent) + "/" + str(perk.levels)
		perkButton.connect("pressed", self, "_select_perk", [key])
		tabPerksButtonsContainer.add_child(perkButton)
	
	populate_fields()
	
func populate_fields():
	if (global.selectedHero.showMyHelm):
		buttonShowHelm.set_pressed(true)
	else:
		buttonShowHelm.set_pressed(false)
		
	if (global.selectedHero.level < global.surnameLevel):
		buttonRename.set_disabled(true)
		label_heroName.text = global.selectedHero.get_first_name()
	else:
		buttonRename.set_disabled(false)
		label_heroName.text = global.selectedHero.get_first_name() + " " + global.selectedHero.heroLastName
	
	if (global.selectedHero.recruited):
		buttonTrainOrRecruit.text = "Train to next level"
	else:
		buttonTrainOrRecruit.text = "Recruit hero"
		buttonRename.hide()
		buttonDismiss.hide()
		progressBar.hide()
		
	if (global.selectedHero.dead):
		buttonDismiss.set_disabled(true)
		buttonRevive.set_disabled(false)
		buttonTrainOrRecruit.set_disabled(true)
	else:
		#hero was just revived
		buttonDismiss.set_disabled(false)
		buttonRevive.set_disabled(true)
		buttonTrainOrRecruit.set_disabled(false)
		var inventoryButtons = get_tree().get_nodes_in_group("InventoryButtons")
		for button in inventoryButtons:
			button.set_disabled(false)
		
		# tint the hero clear again
		var heroScene = get_tree().get_nodes_in_group("heroScene")
		heroScene[0].modulate = Color(1, 1, 1)
		
		
	#disable train button if hero is recruited and at max level
	if (global.selectedHero.recruited && global.selectedHero.level >= global.maxHeroLevel):
		buttonTrainOrRecruit.set_disabled(true)
		buttonTrainOrRecruit.text = "Max level"
	
	_update_perks_tab()
	_update_stats()
	
func _process(delta):
	if (global.selectedHero.staffedTo == "training"):
		#staffedToID = "training1" etc 
		label_xp.text = "TRAINING TO LEVEL " + str(global.selectedHero.level+1)
		
		var trainingData = global.training[global.selectedHero.staffedToID] #get the matching training room data
		if (trainingData.inProgress && !trainingData.readyToCollect):
			var currentTime = OS.get_unix_time()
			if (currentTime >= trainingData.endTime):
				trainingData.readyToCollect = true
			
			buttonTrainOrRecruit.text = util.format_time(trainingData.endTime - OS.get_unix_time())
			var totalTimeToTrain = staticData.levelXpData[str(global.selectedHero.level)].trainingTime
			var progressBarValue = (100 * (totalTimeToTrain - (trainingData.endTime - OS.get_unix_time())) / totalTimeToTrain)
			#General formula:
			#100 * ((total time to finish - timer time left) / total time to finish)
			#60 - 40 / 60 =    20 / 60    = .33    x 100 = 33 
	
			progressBar.set_value(progressBarValue)
		
		if (trainingData.inProgress && trainingData.readyToCollect):
			progressBar.set_value(100)
			buttonTrainOrRecruit.text = "Complete training!"
			
func _update_perks_tab():
	#display perk points to spend 
	field_perkPoints.text = str(global.selectedHero.perkPoints) + " available"
	#get all the buttons and update their data 
	var perkButtons = tabPerksButtonsContainer.get_children()
	var perkKeys = global.selectedHero.perks.keys() #an array of perk names 
	
	for i in (perkButtons.size()):
		var perk = global.selectedHero.perks[perkKeys[i]]
		perkButtons[i].text = perk.perkName + " " + str(perk.pointsSpent) + "/" + str(perk.levels)
	
	#disable the buy perk button if the hero has no perk points to spend
	var perk = global.selectedHero.perks[perkOnDeckKey]
	if (perk.pointsSpent < perk.levels && global.selectedHero.perkPoints > 0): #if there are still levels to buy of this perk 
		# if you can still spend more here AND you have points to spend, enable button
		button_buyPerk.set_disabled(false)
		button_buyPerk.text = "BUY PERK"
	else:
		button_buyPerk.set_disabled(true)
		if (perk.pointsSpent == perk.levels):
			button_buyPerk.text = "PERK FULL!"
			
	if (perk.pointsSpent >= 1):
		button_refundPerks.set_disabled(false)
	else:
		button_refundPerks.set_disabled(true)
	
func _update_stats():
	var aliveStatus = ""
	if (global.selectedHero.dead):
		aliveStatus = "(Dead)"
	else:
		aliveStatus = ""
	label_levelAndClass.text = str(global.selectedHero.level) + " " + global.selectedHero.charClass + " " + aliveStatus
	label_xp.text = "XP: " + str(global.selectedHero.xp) + "/" + str(staticData.levelXpData[str(global.selectedHero.level)].total)
	progressBar.set_value(100 * (global.selectedHero.xp / staticData.levelXpData[str(global.selectedHero.level)].total))
	displayHP._update_fields("HP", str(global.selectedHero.hpCurrent) + " / " + str(global.selectedHero.hp))
	if (global.selectedHero.charClass != "Warrior" && global.selectedHero.charClass != "Rogue" && global.selectedHero.charClass != "Ranger"):
		displayMana._update_fields("Mana", str(global.selectedHero.manaCurrent) + " / " + str(global.selectedHero.mana))
	else:
		displayMana.hide()
		displayManaRegen.hide()
	#stats
	displayArmor._update_fields("Armor", global.selectedHero.armor)
	displayDPS._update_fields("DPS", global.selectedHero.dps)
	displaySTR._update_fields("STR", global.selectedHero.strength)
	displayDEF._update_fields("DEF", global.selectedHero.defense)
	displayINT._update_fields("INT", global.selectedHero.intelligence)
	
	displayHPRegen._update_fields("HP Regen", global.selectedHero.regenRateHP)
	displayManaRegen._update_fields("Mana Regen", global.selectedHero.regenRateMana)
	displayCritChance._update_fields("Crit Chance", str(global.selectedHero.criticalHitChance) + "%")
	#skills
	displaySkillAlchemy._update_fields("Alchemy", global.selectedHero.skillAlchemy)
	displaySkillBlacksmithing._update_fields("Blacksmithing", global.selectedHero.skillBlacksmithing)
	displaySkillChronomancy._update_fields("Chronomancy", global.selectedHero.skillChronomancy)
	displaySkillFletching._update_fields("Fletching", global.selectedHero.skillFletching)
	displaySkillJewelcraft._update_fields("Jewelcraft", global.selectedHero.skillJewelcraft)
	displaySkillTailoring._update_fields("Tailoring", global.selectedHero.skillTailoring)
	displaySkillHarvesting._update_fields("Harvesting", global.selectedHero.skillHarvesting)
	
	#attributes
	displayDrama._update_fields("Drama", global.selectedHero.drama)
	displayMood._update_fields("Mood", global.selectedHero.mood)
	displayPrestige._update_fields("Prestige", global.selectedHero.prestige)
	displayGroupBonus._update_fields("Group Bonus", global.selectedHero.groupBonus)
	displayRaidBonus._update_fields("Raid Bonus", global.selectedHero.raidBonus)
	
func check_name_input(userInput):
	#this is for SURNAMES
	#surnames are more flexible than first names
	#surnames can have spaces, multiple caps, and apostrophes 
	var regex = RegEx.new()
	regex.compile("[A-Za-z. '`]*")
	var result = regex.search(userInput)
	if (result):
		$confirm_rename_dialog.set_candidate_name(result.get_string())
	else:
		print("no result")

		
func _calc_finish_now_cost():
	#Business logic: 
	#1 chrono for every 10 mins of time remaining with a minimum of 1 chrono 
	#plus
	#1 chrono for every 2 levels the hero has 
	
	var trainingData = global.training[global.selectedHero.staffedToID] #get this particular instance of training
	var secondsRemaining = trainingData.endTime - OS.get_unix_time()
	#timeRemaining is in seconds, so to get minutes, divide by 60
	var minutesRemaining = secondsRemaining / 60
	var tensOfMinutesRemaining = minutesRemaining / 10 
	
	#now determine how many chrono are added because of hero levels
	var levelsToChrono = (global.selectedHero.level / 2)
	var cost = tensOfMinutesRemaining + levelsToChrono
	if (cost < 1):
		cost = 1
	return cost
	
func _on_button_train_or_recruit_pressed():
	if (global.selectedHero.recruited && global.selectedHero.level < global.maxHeroLevel):
		if (global.selectedHero.staffedTo == "training"):
			#hero is already in training by whatever means 
			var inProgress = global.training[global.selectedHero.staffedToID].inProgress
			var readyToCollect = global.training[global.selectedHero.staffedToID].readyToCollect
			if (inProgress && !readyToCollect):
				#training in progress
				var finishNowCost = _calc_finish_now_cost() 
				finishNowPopup._set_data("Training", finishNowCost)
				finishNowPopup.popup()
			elif (inProgress && readyToCollect):
				#done training, "free" the hero
				global.training[global.selectedHero.staffedToID].inProgress = false
				global.training[global.selectedHero.staffedToID].readyToCollect = false
				global.training[global.selectedHero.staffedToID].hero = null
				global.selectedHero.send_home()
				global.selectedHero.level_up()
				populate_fields()
		elif (global.selectedHero.xp == staticData.levelXpData[str(global.selectedHero.level)].total):
			#hero is ready to train and not already training
			#assign hero to the lowest-numbered open training spot
			for i in range(0,5):
				if (!global.training["training"+str(i)].hero):
					global.training["training"+str(i)].hero = global.selectedHero
					global.selectedHero.staffedTo = "training"
					global.selectedHero.staffedToID = "training"+str(i)
					global.training["training"+str(i)].inProgress = true
					global.training["training"+str(i)].readyToCollect = false
					global.training["training"+str(i)].endTime = OS.get_unix_time() + staticData.levelXpData[str(global.selectedHero.level)].trainingTime
					populate_fields()
					break
			#todo: handle no open spot found case and show popup
			if (global.selectedHero.staffedTo != "training"):
				print("no room")
		elif (global.selectedHero.xp < staticData.levelXpData[str(global.selectedHero.level)].total):
			#hero is not ready to train, offer instant train instead
			var chronoCost = util.calc_instant_train_cost()
			$confirm_instant_train/RichTextLabel.text = global.selectedHero.get_first_name() + " doesn't have enough XP to train to the next level. Do you want to INSTANT TRAIN for " + str(chronoCost) + " Chrono?"
			$confirm_instant_train.popup()
		else:
			print('heroPage.gd line 296 - bad state')
			
	else: #hero not part of guild yet
		#print("heroPage.gd: Recruiting this hero: " + global.selectedHero.heroName)
		#loop through unrecruited hero array and find the one that we're viewing
		
		#first, see if we have space for this hero
		if (global.guildRoster.size() >= global.guildCapacity):
			get_node("insufficient_guild_capacity_dialog").popup()
		elif (global.guildRoster.size() < global.guildCapacity):
			for i in range(global.unrecruited.size()):
				if (global.unrecruited[i].heroID == global.selectedHero.heroID):
					#change recruited boolean to true and append to guildRoster
					global.unrecruited[i].recruited = true
					global.unrecruited[i].currentRoom = 1
					global.unrecruited[i].idleAt = "main"
					global.guildRoster.append(global.unrecruited[i])
					# assign to a bedroom
					global.unrecruited[i].auto_assign_bedroom()
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

# Note: March 2019 - tried to implement changing first name and couldn't
# find a good flow for validating that the name input is valid before applying it
# to the hero and surfacing any errors to the player. Best to keep it to surname
# changes only for now.
func _on_button_rename_pressed():
	$confirm_rename_dialog.set_mode("last")
	get_node("confirm_rename_dialog").popup()
	
func _on_button_dismiss_pressed():
	get_node("confirm_dismiss_dialog").popup()

func _on_rename_dialogue_confirmed():
	var newName = $confirm_rename_dialog/LineEdit.text
	global.selectedHero.set_first_name(newName)
	#redraw the name display field on the hero page with the new name
	label_heroName.text = global.selectedHero.get_first_name()
	
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
	var cost = util.calc_instant_train_cost()
	if (global.hardCurrency >= cost):
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time
		global.hardCurrency -= cost
		global.selectedHero.level_up()
		#$progress_xp.set_value(100 * (global.selectedHero.xp / global.levelXpData[global.selectedHero.level].total))
		_update_stats()
		populate_fields()
	else: 
		print("heroPage.gd: not enough Chrono")

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
	
func _on_button_revive_pressed():
	global.selectedHero.dead = false
	global.selectedHero.hpCurrent = global.selectedHero.hp
	global.selectedHero.manaCurrent = global.selectedHero.mana
	populate_fields()

func _on_button_fullXP_pressed():
	global.selectedHero.xp = staticData.levelXpData[str(global.selectedHero.level)].total
	_update_stats()

func _select_perk(key):
	var perk = global.selectedHero.perks[key]
	field_perkDescription.text = perk.perkName + "\n\n" + perk.description
	perkOnDeckKey = key
	_update_perks_tab()
	
func _on_Button_perkPoint_pressed():
	global.selectedHero.give_perk_points(1)
	_update_perks_tab()

func _on_button_buyPerk_pressed():
	var perk = global.selectedHero.perks[perkOnDeckKey]
	if (perk.pointsSpent < perk.levels):
		if (global.selectedHero.perkPoints >= 1):
			global.selectedHero.take_perk_points(1)
			global.selectedHero.perks[perkOnDeckKey].pointsSpent += 1
			global.selectedHero.update_hero_stats()
		else:
			print("Not enough perk points to buy this perk.")
	else:
		print("This perk is full")
	_update_perks_tab()
	_update_stats()
	
func _on_button_refundPerks_pressed():
	# give all spent perk points back to hero
	# preserve any unspent perk points
	# empty out all perk spending 
	# redraw ui
	if (global.hardCurrency >= 2):
		var perksWithPoints = global.selectedHero.perks.keys()
		for perkName in perksWithPoints:
			var refund = global.selectedHero.perks[perkName].pointsSpent
			global.selectedHero.give_perk_points(refund)
			global.selectedHero.perks[perkName].pointsSpent = 0
			
		global.selectedHero.update_hero_stats()
		_update_perks_tab()
		_update_stats()
		global.hardCurrency -= 2
	else:
		print("Insufficient Chrono")

func _redraw_hero():
	#it's the only thing in this group
	var heroScenes = get_tree().get_nodes_in_group("heroScene")
	var heroScene = heroScenes[0]
	heroScene.set_instance_data(global.selectedHero) #put data from array into scene 
	heroScene._draw_sprites()
	 
func _on_button_helm_pressed():
	global.selectedHero.showMyHelm = !global.selectedHero.showMyHelm
	populate_fields()
	_redraw_hero()