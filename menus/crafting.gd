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
		recipeButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing) #todo: fix 
		recipeButton.set_recipe_data(tradeskill.recipes[i])
		recipeButton.set_position(Vector2(0, yVal))
		recipeButton.connect("updateRecipe", self, "_update_ingredients")
		$scroll/vbox.add_child(recipeButton)
		yVal += 40
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
		
func _update_ingredients():
	#called any time the user selects a recipe 
	recipe = tradeskill.selectedRecipe #make a local copy so we don't have to use a long reference
	
	$recipeData/field_recipeName.text = recipe.recipeName
	if (recipe.noFail):
		$recipeData/field_success.text = "No fail"
	else:
		$recipeData/field_success.text = "Chance to fail"
	
	$recipeData/field_craftingTime.text = util.format_time(recipe.craftingTime)
	
	if (tradeskill.inProgress):
		var itemName = tradeskill.currentlyCrafting.name
		if (tradeskill.wildcardItem):
			$recipeData/field_nowCrafting.text = "Now Crafting: Improved " + itemName
		else:
			$recipeData/field_nowCrafting.text = "Now Crafting: " + itemName
	else:
		$recipeData/field_nowCrafting.text = "Now Crafting: Nothing"
		
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
		$recipeData/ingredientWildcard.show()
		$recipeData/ingredientWildcard._set_enabled()
		global.browsingForType = recipe.ingredientWildcard #contains the type, such as "blade" 
		if (tradeskill.wildcardItem):
			hasWildcardIngredient = true
			#if the user picked an item to be the wildcard item, show it here 
			$recipeData/label_choose.hide()
			$recipeData/ingredientWildcard._render_tradeskill(global.tradeskills[global.currentMenu].wildcardItem)
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
	
	#determine which ingredients to display and whether the text is red or green 
	if (recipe.ingredient1): #if this recipe has a first ingredient
		$recipeData/ingredient1._render_fields(global.allGameItems[str(recipe.ingredient1)])
		if (global.tradeskillItemsDictionary[recipe.ingredient1].count > 0): #and we have it in the tradeskill items dictionary
			$recipeData/ingredient1._set_green()
		else:
			$recipeData/ingredient1._set_red()
	else:
		$recipeData/ingredient1._clear_fields()
		
	if (recipe.ingredient2):
		$recipeData/ingredient2._render_fields(global.allGameItems[str(recipe.ingredient2)])
		if (global.tradeskillItemsDictionary[recipe.ingredient2].count > 0): 
			$recipeData/ingredient2._set_green()
		else:
			$recipeData/ingredient2._set_red()
	else:
		$recipeData/ingredient2._clear_fields()
		
	if (recipe.ingredient3):
		$recipeData/ingredient3._render_fields(global.allGameItems[str(recipe.ingredient3)])
		if (global.tradeskillItemsDictionary[recipe.ingredient3].count > 0):
			$recipeData/ingredient3._set_green()
		else:
			$recipeData/ingredient3._set_red()
	else:
		$recipeData/ingredient3._clear_fields()
		
	if (recipe.ingredient4): 
		$recipeData/ingredient4._render_fields(global.allGameItems[str(recipe.ingredient4)])
		if (global.tradeskillItemsDictionary[recipe.ingredient4].count > 0): 
			$recipeData/ingredient4._set_green()
		else:
			$recipeData/ingredient4._set_red()
	else:
		$recipeData/ingredient4._clear_fields()
		
func _process(delta):
	#Displays how much time is left on the active recipe 
	if (tradeskill.inProgress && !tradeskill.readyToCollect):
		#print("time left: " + str(tradeskill.timer.time_left))
		$button_combine.set_text(util.format_time(tradeskill.timer.time_left))
		#to get the percent, we need to know how long this recipe takes and how much time has elapsed
		#divide time elapsed by time needed to complete
		$recipeData/progress_nowCrafting.set_value(100 * ((tradeskill.currentlyCrafting.totalTimeToFinish - tradeskill.timer.time_left) / tradeskill.currentlyCrafting.totalTimeToFinish))
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		$button_combine.set_text("COLLECT!")
		$button_combine.add_color_override("font_color", global.colorYellow) #239, 233, 64 yellow
		$recipeData/progress_nowCrafting.set_value(100)
	else:
		$button_combine.set_text("COMBINE")
		$button_combine.add_color_override("font_color", global.colorWhite) #white

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
		$finishedItem_dialog/elements/field_skillUp.text = tradeskill.hero.heroName + " became better at " + tradeskill.displayName + " (" + str(global.tradeskills[global.currentMenu].hero.skillBlacksmithing) + ")"
		$finishedItem_dialog/elements/field_skillUp.show()
		_update_hero_skill_display()
	else:
		$finishedItem_dialog/elements/field_skillUp.hide()
	
	$finishedItem_dialog/elements/sprite_icon.texture = load("res://sprites/items/" + global.allGameItems[str(tradeskill.currentlyCrafting.name)].icon)
	#since we don't actually create the item until it is collected,
	#we can't use its final name yet. This "fakes" it - 
	if (tradeskill.wildcardItem):
		$finishedItem_dialog/elements/field_itemName.text = "Improved " + tradeskill.currentlyCrafting.name
	else:
		$finishedItem_dialog/elements/field_itemName.text = tradeskill.currentlyCrafting.name
	$finishedItem_dialog.popup()

func _on_finishedItem_dialog_confirmed():
	#these things happen when the player dismisses the "COMPLETE!" popup affirmatively
	if (!tradeskill.currentlyCrafting.statImproved):
		#this was a "normal" recipe, not a wildcard item recipe
		util.give_item_guild(tradeskill.currentlyCrafting.name)
	else:
		
		#this is a "computed" item, use a different util method to give it to the guild with mods
		util.give_modded_item_guild(
						tradeskill.currentlyCrafting.name,
						global.currentMenu, 
						tradeskill.currentlyCrafting.statImproved, 
						tradeskill.currentlyCrafting.statIncrease) #give the modified item to the guild inventory

	$recipeData/progress_nowCrafting.set_value(0)
	tradeskill.timer.stop()
	tradeskill.wildcardItem = null
	tradeskill.inProgress = false
	tradeskill.readyToCollect = false
	tradeskill.currentlyCrafting.name = null
	tradeskill.currentlyCrafting.statImproved = null
	tradeskill.currentlyCrafting.statIncrease = null
	_update_ingredients()
	
func _ingredient_check():
	var readyToCombine = true
	if (recipe.ingredient1 && global.tradeskillItemsDictionary[recipe.ingredient1].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient2 && global.tradeskillItemsDictionary[recipe.ingredient2].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient3 && global.tradeskillItemsDictionary[recipe.ingredient3].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient4 && global.tradeskillItemsDictionary[recipe.ingredient4].count == 0):
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
			
			#take ingredients away from player by name (these are fungible, just take the first instance)
			if (recipe.ingredient1):
				if (global.tradeskillItemsDictionary[recipe.ingredient1].consumable):
					global.tradeskillItemsDictionary[recipe.ingredient1].count -= 1
					#util.remove_item_guild_by_name(recipe.ingredient1)
				
			if (recipe.ingredient2):
				if (global.tradeskillItemsDictionary[recipe.ingredient2].consumable):
					global.tradeskillItemsDictionary[recipe.ingredient2].count -= 1
			
			if (recipe.ingredient3):
				if (global.tradeskillItemsDictionary[recipe.ingredient3].consumable):
					global.tradeskillItemsDictionary[recipe.ingredient3].count -= 1
				
			if (recipe.ingredient4):
				if (global.tradeskillItemsDictionary[recipe.ingredient4].consumable):
					global.tradeskillItemsDictionary[recipe.ingredient4].count -= 1
					
			#todo: refactor to use ID, these are specific items from the vault
			if (recipe.ingredientWildcard):
				util.remove_item_guild_by_id(tradeskill.wildcardItem.itemID)
			
			global._begin_tradeskill_timer(tradeskill.selectedRecipe.craftingTime)
			_update_ingredients()
				
	elif (tradeskill.inProgress && !tradeskill.readyToCollect):
		#todo: cost logic for speeding up a recipe is based on trivial level of recipe and time left 
		finishNowPopup._set_data("Tradeskill", 2)
		finishNowPopup.popup()
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		_open_collect_result_popup()
	else:
		print("crafting.gd - got in some weird state")
	
func _on_button_dismissHero_pressed():
	#first, see if a recipe is active
	if (tradeskill.inProgress && !tradeskill.readyToCollect):
		finishNowPopup._set_data("Tradeskill", 2, "You cannot unstaff while crafting is in progress")
		finishNowPopup.popup()
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		#todo: make global error popup
		print("Collect results before unstaffing")
	else:
		tradeskill.hero.currentRoom = 1
		tradeskill.hero.atHome = true
		tradeskill.hero.staffedTo = ""
		tradeskill.hero = null
		get_tree().change_scene("res://main.tscn")
