extends Node2D
#createHero.gd

var heroGenerator = load("res://heroGenerator.gd").new()
var nameGenerator = load("res://nameGenerator.gd").new()
var heroScene = null

var allHumanHeads = []
var headIndex = -1

func _ready():
	#generate a hero
	heroGenerator.generate(global.guildRoster, "Cleric")
	
	#the new hero is the last thing in the roster, so grab it out of the back
	var lastIndex = global.guildRoster.size() - 1
	global.selectedHero = global.guildRoster[lastIndex]
	
	#for now, this new hero can only be human
	#but we need all the human heads in one big array so this page can cycle through them
	allHumanHeads = []
	for head in global.selectedHero.humanFemaleHeads:
		allHumanHeads.append(head)
	for head in global.selectedHero.humanMaleHeads:
		allHumanHeads.append(head)
	#and figure out where this hero's randomly picked head is in that big array
	for i in allHumanHeads.size():
		if (allHumanHeads[i] == global.selectedHero.headSprite):
			headIndex = i
	
	$confirm_rename_dialog.set_mode("first")
	$confirm_rename_dialog.connect("redrawHeroName", self, "update_hero_preview")
	$confirm_rename_dialog/LineEdit.connect("text_changed", self, "check_name_input") #, ["userInput"]
	
	draw_hero_scene()

func draw_hero_scene():
	heroScene = preload("res://hero.tscn").instance()
	heroScene.set_instance_data(global.selectedHero)
	heroScene._draw_sprites()
	heroScene.set_position(Vector2(240, 80)) #screen is 540 wide 
	heroScene.set_display_params(false, true) #walking enabled?, show name 
	add_child(heroScene)
	
func _on_button_rename_pressed():
	$confirm_rename_dialog.set_mode("first")
	get_node("confirm_rename_dialog").popup()

func update_hero_preview():
	heroScene.free()
	draw_hero_scene()
	
func check_name_input(userInput):
	#this is for FIRST NAMES
	#Rules are more strict here, no punctuation and first letter must be a capital 
	var regex = RegEx.new()
	regex.compile("[A-Za-z'`]*")
	var result = regex.search(userInput)
	if (result):
		$confirm_rename_dialog.set_candidate_name(result.get_string().to_lower().capitalize())
	else:
		print("no result")
	
func _on_button_cleric_pressed():
	global.selectedHero.change_class("Cleric")
	update_hero_preview()

func _on_button_druid_pressed():
	global.selectedHero.change_class("Druid")
	update_hero_preview()

func _on_button_ranger_pressed():
	global.selectedHero.change_class("Ranger")
	update_hero_preview()

func _on_button_rogue_pressed():
	global.selectedHero.change_class("Rogue")
	update_hero_preview()

func _on_button_warrior_pressed():
	global.selectedHero.change_class("Warrior")
	update_hero_preview()

func _on_button_wizard_pressed():
	global.selectedHero.change_class("Wizard")
	update_hero_preview()

func _on_button_prevHead_pressed():
	headIndex -= 1
	#if we've gone out of the left bound, wrap around to end
	if (headIndex < 0):
		headIndex = allHumanHeads.size() - 1
	global.selectedHero.change_head(allHumanHeads[headIndex])
	update_hero_preview()

func _on_button_nextHead_pressed():
	#if this click takes us out of the right bound, wrap around to start
	headIndex += 1
	if (headIndex > allHumanHeads.size() -1):
		headIndex = 0
	global.selectedHero.change_head(allHumanHeads[headIndex])
	update_hero_preview()

func _on_button_randomName_pressed():
	global.selectedHero.heroFirstName = nameGenerator.generateFirst("any")
	update_hero_preview()
	
func _on_button_createHero_pressed():
	get_tree().change_scene("res://main.tscn")
