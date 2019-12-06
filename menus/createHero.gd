extends Node2D
#createHero.gd

var heroGenerator = load("res://heroGenerator.gd").new()
var nameGenerator = load("res://nameGenerator.gd").new()
var heroScene = null

var allHumanHeads = []
var headIndex = -1
var defaultClassStr = "Cleric" #todo: randomize

onready var field_classDescription = $VBoxContainer/CenterContainer/field_classDescription
onready var button_createHero = $VBoxContainer/CenterContainer2/button_createHero
onready var label_nameDupe = $VBoxContainer/label_nameDupe
onready var label_nameTooShort = $VBoxContainer/label_nameTooShort

func _ready():
	label_nameDupe.hide()
	label_nameTooShort.hide()
	
	#generate a hero
	heroGenerator.generate(global.guildRoster, defaultClassStr)
	
	#the new hero is the last thing in the roster, so grab it out of the back
	var lastIndex = global.guildRoster.size() - 1
	global.selectedHero = global.guildRoster[lastIndex]
	global.selectedHero.isPlayer = true
	
	# give it a bedroom spot
	heroGenerator._auto_assign_bedroom(global.selectedHero)
	
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
	$confirm_rename_dialog.connect("heroNameUpdated", self, "update_hero_preview") #update_hero_preview
	$confirm_rename_dialog.connect("heroNameInvalid", self, "_name_invalid")
	$confirm_rename_dialog/LineEdit.connect("text_changed", self, "sanitize_name_input") #, ["userInput"]
	
	draw_hero_scene()
	_set_class(defaultClassStr)

	# run validation on current selections (names, points spent)
	_check_valid()

func draw_hero_scene():
	heroScene = preload("res://baseEntity.tscn").instance()
	heroScene.set_script(preload("res://hero.gd"))
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
	_check_valid()
	
func _name_invalid(nameStr):
	if (nameStr != ""):
		label_nameDupe.text = nameStr + " is already in use. Choose a different name!"
		label_nameDupe.show()
	elif (nameStr == ""):
		print(nameStr + " is an empty name")
		label_nameTooShort.text = "Alas, your name cannot be blank."
		label_nameTooShort.show()
	
func _check_valid():
	# check points spent (todo)
	button_createHero.set_disabled(false)
	
	
func sanitize_name_input(userInput):
	#this is for FIRST NAMES and the check runs every character input
	#Rules are more strict here
	#No duplication of existing names, no punctuation and first letter must be a capital 
	
	# One exception is made: two-letter initials are allowed IF that's how the player
	# entered it (ie: AJ)
	if (userInput.length() <= 2):
		# if the player input is given as one or two capital letters, let that pass
		var regex = RegEx.new()
		regex.compile("[A-Z]*") #use + instead of * to actually get a null result
		var result = regex.search(userInput)
		if (result.get_string() == userInput):
			#the user entered one or two letters and they are both capitalized - accept it
			$confirm_rename_dialog.set_candidate_name(result.get_string())
		else:
			# the user entered one or two letters and one or both are not capitalized 
			# correct it into this form: Hi 
			$confirm_rename_dialog.set_candidate_name(userInput.to_lower().capitalize())
	else:
		var regex = RegEx.new()
		regex.compile("[A-Za-z'`]+")
		var result = regex.search(userInput) # get just the parts that match the regex pattern
		if (result):
			$confirm_rename_dialog.set_candidate_name(result.get_string().to_lower().capitalize())
		else:
			#result is null
			print("result is null")
			
		
func _set_class(classStr):
	global.selectedHero.set_hero_class(classStr)
	update_hero_preview()
	update_class_text(classStr)
	
func _on_button_cleric_pressed():
	_set_class("Cleric")

func _on_button_druid_pressed():
	_set_class("Druid")

func _on_button_ranger_pressed():
	_set_class("Ranger")

func _on_button_rogue_pressed():
	_set_class("Rogue")

func _on_button_warrior_pressed():
	_set_class("Warrior")

func _on_button_wizard_pressed():
	_set_class("Wizard")

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
	global.selectedHero.set_first_name(nameGenerator.generateFirst("any"))
	update_hero_preview()
	
func update_class_text(classNameStr):
	field_classDescription.text = staticData.heroStats[classNameStr.to_lower()].description
	
func _on_button_createHero_pressed():
	global.namesInUse.append(global.selectedHero.get_first_name())
	get_tree().change_scene("res://main.tscn")
