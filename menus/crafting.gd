extends Node2D
#crafting.gd
onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()
var util = load("res://util.gd").new()
var hasIngredient1 = false
var hasIngredient2 = false
var hasIngredient3 = false
var hasIngredient4 = false
var hasWildcardIngredient = false
var recipe = null
var tradeskill = null 

func _ready():
	add_child(finishNowPopup)
	tradeskill = global.tradeskills[global.currentMenu] #tradeskill object defined in global.gd
	$field_craftingSkillName.text = tradeskill.displayName
	$field_description.text = tradeskill.description
	#todo: maybe vbox is the wrong container type to use, since the auto spacing doesn't work in this case
	#print all the available recipes
	var yVal = 0
	for i in range(tradeskill.recipes.size()):
		var recipeButton = preload("res://menus/recipeButton.tscn").instance()
		recipeButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing)
		recipeButton.set_recipe_data(tradeskill.recipes[i])
		recipeButton.set_position(Vector2(0, yVal))
		recipeButton.connect("updateRecipe", self, "_update_ingredients")
		$scroll/vbox.add_child(recipeButton)
		yVal += 32
	_update_ingredients()
	_update_hero_skill_display()
	
#todo: refactor out 
func _update_hero_skill_display():
	var skillNum = 0
	if (global.currentMenu == "blacksmithing"):
		skillNum = tradeskill.hero.skillBlacksmithing
	elif (global.currentMenu == "tailoring"):
		skillNum = tradeskill.hero.skillTailoring
	elif (global.currentMenu == "jewelcraft"):
		skillNum = tradeskill.hero.skillJewelcraft
	elif (global.currentMenu == "alchemy"):
		skillNum = tradeskill.hero.skillAlchemy
	elif (global.currentMenu == "fletching"):
		skillNum = tradeskill.hero.skillFletching
		
	$field_heroSkill.text = tradeskill.hero.heroName + " skill level: " + str(tradeskill.hero.skillBlacksmithing)
		
#todo: genericize to handle any recipe type
func _update_ingredients():
	#called any time the user selects a recipe 
	recipe = tradeskill.selectedRecipe #make a local copy so we don't have to use a long reference
	
	$recipeData/field_recipeName.text = recipe.recipeName
	if (recipe.noFail):
		$recipeData/field_success.text = "No fail"
	else:
		$recipeData/field_success.text = "Chance to fail"
	
	$recipeData/field_craftingTime.text = str(recipe.craftingTime) + "s"
	
	#result item or stat increase display 
	if (recipe.result):
		if (recipe.result == "computed"):
			$recipeData/resultItem.hide()
			$recipeData/label_computed.show()
			$recipeData/label_computed.text = "+" +str(recipe.statIncrease) + " " + str(recipe.statImproved)
		else:
			$recipeData/resultItem.show()
			$recipeData/label_computed.hide()
			$recipeData/resultItem._render_tradeskill(global.allGameItems[str(recipe.result)])
	
	#every recipe has at least one ingredient
	#but some recipes let you pick what that ingredient actually is (ie: a sword for sharpening)
	#decorate the ingredient buttons accordingly 
		
	#ingredient wildcard is an itemButton instance 
	if (recipe.ingredientWildcard):
		print("crafting.gd - this recipe has a wildcard ingredient")
		$recipeData/ingredientWildcard.show()
		$recipeData/ingredientWildcard._set_enabled()
		global.browsingForType = recipe.ingredientWildcard #contains the type, such as "blade" 
		if (tradeskill.wildcardItem):
			hasWildcardIngredient = true
			#if the user picked an item to be the wildcard item, show it here 
			$recipeData/label_choose.hide()
			$recipeData/ingredientWildcard._render_tradeskill(global.allGameItems[str(tradeskill.wildcardItem.name)])
		else:
			hasWildcardIngredient = false
			$recipeData/label_choose.show()
			$recipeData/ingredientWildcard._clear_tradeskill()
	else:
		tradeskill.wildcardItem = null
		hasWildcardIngredient = false
		$recipeData/ingredientWildcard._render_tradeskill(global.allGameItems[str(recipe.ingredient1)])
		$recipeData/label_choose.hide()
		$recipeData/ingredientWildcard.hide()
	
	#determine which items the player actually has and display accordingly
	hasIngredient1 = false
	hasIngredient2 = false
	hasIngredient3 = false
	hasIngredient4 = false
	for i in range(global.guildItems.size()):
		if (global.guildItems[i]):
			if (recipe.ingredient1): #if this recipe has a first ingredient
				if (global.guildItems[i].name == recipe.ingredient1): #and we found it in the guild vault
					hasIngredient1 = true #then set to true
			
			if (recipe.ingredient2):
				if (global.guildItems[i].name == recipe.ingredient2):
					hasIngredient2 = true
				
			if (recipe.ingredient3):
				if (global.guildItems[i].name == recipe.ingredient3):
					hasIngredient3 = true
				
			if (recipe.ingredient4):
				if (global.guildItems[i].name == recipe.ingredient4):
					hasIngredient4 = true
			
	#the rest of these are just display fields with icon and text 
	if (recipe.ingredient1):
		$recipeData/ingredient1._render_fields(global.allGameItems[str(recipe.ingredient1)])
		if (hasIngredient1):
			$recipeData/ingredient1._set_green()
		else:
			$recipeData/ingredient1._set_red()
	else:
		$recipeData/ingredient1._clear_fields()
		
	if (recipe.ingredient2):
		$recipeData/ingredient2._render_fields(global.allGameItems[str(recipe.ingredient2)])
		if (hasIngredient2):
			$recipeData/ingredient2._set_green()
		else:
			$recipeData/ingredient2._set_red()
	else:
		$recipeData/ingredient2._clear_fields()
		
	if (recipe.ingredient3):
		$recipeData/ingredient3._render_fields(global.allGameItems[str(recipe.ingredient3)])
		if (hasIngredient3):
			$recipeData/ingredient3._set_green()
		else:
			$recipeData/ingredient3._set_red()
	else:
		$recipeData/ingredient3._clear_fields()
		
	if (recipe.ingredient4):
		$recipeData/ingredient4._render_fields(global.allGameItems[str(recipe.ingredient4)])
		if (hasIngredient4):
			$recipeData/ingredient4._set_green()
		else:
			$recipeData/ingredient4._set_red()
	else:
		$recipeData/ingredient4._clear_fields()

		
func _process(delta):
	#Displays how much time is left on the active recipe 
	if (tradeskill.inProgress && !tradeskill.readyToCollect):
		$button_combine.set_text(util.format_time(tradeskill.timer.time_left))
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		$button_combine.set_text("COLLECT!")
		$button_combine.add_color_override("font_color", Color(.93, .913, .25, 1)) #239, 233, 64 yellow
	else:
		$button_combine.set_text("COMBINE")
		$button_combine.add_color_override("font_color", Color(1, 1, 1, 1)) #white
		
func _on_button_back_pressed():
	#todo: only clear it if it's not in use being upgraded
	tradeskill.wildcardItem = null
	get_tree().change_scene("res://main.tscn")

func _open_collect_result_popup():
	#todo: skill-up chance should use a more sophisticated formula
	#for now, it's just a 50/50 chance that you get a skill-up on combine
	
	#determine skillup and decorate the popup
	var skillUpRandom = randi()%2+1 #1-2
	if (skillUpRandom == 2):
		tradeskill.hero.skillBlacksmithing += 1
		$finishedItem_dialog/elements/field_skillUp.text = tradeskill.hero.heroName + " became better at THIS SKILL! (" + str(global.tradeskills[global.currentMenu].hero.skillBlacksmithing) + ")"
		$finishedItem_dialog/elements/field_skillUp.show()
		_update_hero_skill_display()
	else:
		$finishedItem_dialog/elements/field_skillUp.hide()
		
	#todo: crashes when in the sharpen weapon flow
	if (!tradeskill.wildcardItem): 
		$finishedItem_dialog/elements/sprite_icon.texture = load("res://sprites/items/" + global.allGameItems[str(recipe.result)].icon)
	else: 
		$finishedItem_dialog/elements/sprite_icon.texture = load("res://sprites/items/" + global.allGameItems[str(tradeskill.wildcardItem.name)].icon)
	$finishedItem_dialog/elements/field_itemName.text = tradeskill.selectedRecipe.result
	$finishedItem_dialog.popup()

func _on_finishedItem_dialog_confirmed():
	#these things happen when the player dismisses the popup affirmatively
	#if the recipe is not "sharpening"
	if (!tradeskill.wildcardItem):
		#this is a "normal" recipe, not a wildcard item recipe
		util.give_item_guild(tradeskill.selectedRecipe.result)
	else:
		#get the original item out of the all items dictionary
		var localItem = global.allGameItems[str(tradeskill.wildcardItem.name)]
		localItem.dps += 1 #hardcode to 1 for now 
		util.give_item_guild(localItem.name) #give the modified item to the guild inventory
	
	tradeskill.wildcardItem = null
	tradeskill.inProgress = false
	tradeskill.readyToCollect = false
	_update_ingredients()
	
func _ingredient_check():
	var readyToCombine = true
	if (recipe.ingredient1 && !hasIngredient1):
		readyToCombine = false
		
	if (recipe.ingredient2 && !hasIngredient2):
		readyToCombine = false
		
	if (recipe.ingredient3 && !hasIngredient3):
		readyToCombine = false
		
	if (recipe.ingredient4 && !hasIngredient4):
		readyToCombine = false
		
	if (recipe.ingredientWildcard && !hasWildcardIngredient):
		readyToCombine = false
		
	return readyToCombine
	
func _on_button_combine_pressed():
	if (!tradeskill.inProgress):
		#check if user has ingredients
		var allIngredientsHere = _ingredient_check()
		if (allIngredientsHere == false):
			$incomplete_dialog.popup() #tell the user they don't have all the ingredients
		else:
			#otherwise, start the timer and take ingredients from inventory
			_begin_tradeskill_timer(tradeskill.selectedRecipe.craftingTime)
			#take ingredients away from player
			#todo: some ingredients aren't deleted after one combine - how to distinguish?
			if (recipe.ingredient1):
				if (global.allGameItems[str(recipe.ingredient1)].consumable):
					util.remove_item_guild(recipe.ingredient1)
				
			if (recipe.ingredient2):
				if (global.allGameItems[str(recipe.ingredient2)].consumable):
					util.remove_item_guild(recipe.ingredient2)
			
			if (recipe.ingredient3):
				if (global.allGameItems[str(recipe.ingredient3)].consumable):
					util.remove_item_guild(recipe.ingredient3)
				
			if (recipe.ingredient4):
				if (global.allGameItems[str(recipe.ingredient4)].consumable):
					util.remove_item_guild(recipe.ingredient4)
					
			if (recipe.ingredientWildcard):
				if (global.allGameItems[str(global.tradeskills[global.currentMenu].wildcardItem.name)]):
					#this doesn't seem to be working, there's a duplicate sword generated 
					util.remove_item_guild(global.tradeskills[global.currentMenu].wildcardItem.name)
				
			_update_ingredients()
				
	elif (tradeskill.inProgress && !tradeskill.readyToCollect):
		#todo: cost logic for speeding up a recipe is based on trivial level of recipe and time left 
		finishNowPopup._set_data("Tradeskill", 2)
		finishNowPopup.popup()
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		_open_collect_result_popup()
	else:
		print("crafting.gd - got in some weird state")
		
#tradeskill timer
func _begin_tradeskill_timer(duration):
	if (!tradeskill.inProgress):
		print("global.gd - starting " + global.currentMenu + " timer: " + str(duration))
		tradeskill.inProgress = true
		tradeskill.readyToCollect = false
		tradeskill.timer = Timer.new()
		tradeskill.timer.set_one_shot(true)
		tradeskill.timer.set_wait_time(duration)
		tradeskill.timer.connect("timeout", self, "_on_tradeskillTimer_timeout")
		tradeskill.timer.start()
		add_child(tradeskill.timer)
	else:
		print("global.gd - error: " + tradeskill.name + " timer already running")


func _on_tradeskillTimer_timeout():
	#this is where the quest's random prizes are determined 
	global.logger(self, "tradeskill timer complete!")
	#blacksmithingInProgress = false
	tradeskill.readyToCollect = true
	
func _on_button_dismissHero_pressed():
	tradeskill.hero.currentRoom = 1
	tradeskill.hero = null
	get_tree().change_scene("res://main.tscn")
