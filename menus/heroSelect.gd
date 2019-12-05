extends Node2D
#heroSelect.gd
#use this menu to pick a hero to assign to a quest
onready var heroSelectDescription = $CenterContainer/VBoxContainer/field_heroSelectDescription
onready var scrollVBox = $CenterContainer/VBoxContainer/scroll/vbox

func _ready():
			
	if (global.currentMenu == "alchemy" || 
			global.currentMenu == "blacksmithing" || 
			global.currentMenu == "fletching" || 
			global.currentMenu == "jewelcraft" || 
			global.currentMenu == "tailoring"):
		heroSelectDescription.text = "Choose a hero to work at this tradeskill. Crafting recipes will improve this hero's skill at " + global.currentMenu + ". While here, this hero will not be available for quests or raids."
	elif (global.currentMenu == "harvesting"):
		heroSelectDescription.text = "Choose a hero to harvest this resource."
	elif (global.currentMenu == "selectHeroForCamp"):
		heroSelectDescription.text = "Choose a hero to hunt mobs and win loot at this camp."
	elif (global.currentMenu == "training"):
		heroSelectDescription.text = "Heroes must undergo training to continue to advance in levels. Choose a hero who is 'Ready to Train' to assign them to this training room."
	else:
		heroSelectDescription.text = "heroSelect.gd TEXT NOT SET"
	_draw_hero_buttons()

func _open_rapid_train_popup():
	var chronoCost = util.calc_instant_train_cost()
	$rapid_train_dialog/RichTextLabel.text = global.selectedHero.get_first_name() + " doesn't have enough XP to train to the next level. Do you want to INSTANT TRAIN for " + str(chronoCost) + " Chrono?"
	$rapid_train_dialog.popup()
	
func _on_rapid_train_dialog_confirmed():
	var cost = util.calc_instant_train_cost()
	if (global.hardCurrency >= cost):
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time
		global.hardCurrency -= cost
		global.selectedHero.level_up()
		_update_hero_buttons()
	else: 
		print("heroPage.gd: not enough Chrono")
	
func _draw_hero_buttons():
	var buttonX = 0
	var buttonY = 80
	for i in range(global.guildRoster.size()):
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		heroButton.set_position(Vector2(buttonX, buttonY))
		heroButton.connect("rapidTrain", self, "_open_rapid_train_popup")
		scrollVBox.add_child(heroButton) 
		buttonY += 80
		
func _update_hero_buttons():
	var children = scrollVBox.get_children()
	for i in children.size():
		children[i].set_hero_data(global.guildRoster[i])
	
func _on_button_back_pressed():
	if (global.currentMenu == "alchemy" || 
		global.currentMenu == "blacksmithing" || 
		global.currentMenu == "chronomancy" || 
		global.currentMenu == "fletching" || 
		global.currentMenu == "jewelcraft" || 
		global.currentMenu == "tailoring"):
		global.currentMenu = "main"
		get_tree().change_scene("res://main.tscn")
	elif (global.currentMenu == "training"):
		get_tree().change_scene("res://main.tscn")
	elif (global.currentMenu == "harvesting"):
		#todo: return to correct map 
		get_tree().change_scene("res://menus/maps/forest.tscn")
	elif (global.currentMenu == "selectHeroForCamp"):
		get_tree().change_scene("res://menus/maps/camp.tscn")
	else:
		print("heroSelect.gd - back not handled") 
