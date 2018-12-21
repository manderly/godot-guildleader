extends Node2D
#crafting.gd
onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()
onready var finishedItemPopup = preload("res://menus/popup_finishedItem.tscn").instance()

onready var tradeskillName = $VBoxContainer/field_craftingSkillName
onready var staffedHeroNameAndSkill = $VBoxContainer/CenterContainer/HBoxContainer/field_heroSkill
onready var tradeskillDescription = $VBoxContainer/field_description

onready var ingredient1Display = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer/ingredient1
onready var ingredient2Display = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer/ingredient2
onready var ingredient3Display = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer/ingredient3
onready var ingredient4Display = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer/ingredient4

onready var labelTime = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer2/label_time
onready var labelFailNoFail = $recipeData/hbox_ingredients/HBoxContainer/VBoxContainer2/label_failNoFail

onready var combineButton = $recipeData/VBoxContainer/button_combine
onready var progressBar = $recipeData/VBoxContainer/progress_nowCrafting

onready var nowCrafting = $recipeData/VBoxContainer/field_nowCrafting

onready var labelComputed = $recipeData/VBoxContainer/CenterContainer2/resultItem/label_computed
onready var resultItemBox = $recipeData/VBoxContainer/CenterContainer2/resultItem
onready var wildcardItemBox = $recipeData/hbox_ingredients/ingredientWildcard
onready var labelChoose = $recipeData/VBoxContainer/CenterContainer2/resultItem/label_choose
onready var recipeName = $recipeData/label_ingredients

var hasIngredient1 = false
var hasIngredient2 = false
var hasIngredient3 = false
var hasIngredient4 = false
var hasWildcardIngredient = false
var recipe = null
var tradeskill = null

var recipeButtonGroup

func _ready():
	recipeButtonGroup = ButtonGroup.new()
	
	finishedItemPopup.connect("collectItem", self, "tradeskillItem_callback")
	
	add_child(finishNowPopup)
	add_child(finishedItemPopup)
	
	tradeskill = global.tradeskills[global.currentMenu] #tradeskill object defined in global.gd
	tradeskillName.text = tradeskill.displayName
	tradeskillDescription.text = tradeskill.description
	#todo: maybe vbox is the wrong container type to use, since the auto spacing doesn't work in this case
	#print all the available recipes
	for i in range(tradeskill.recipes.size()):
		var recipeButton = preload("res://menus/recipeButton.tscn").instance()
		recipeButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing) #todo: fix 
		recipeButton.set_recipe_data(tradeskill.recipes[i])
		recipeButton.set_button_group(recipeButtonGroup)
		recipeButton.connect("updateRecipe", self, "_update_ingredients")
		$scroll/vbox.add_child(recipeButton)
	
	if (tradeskill.currentlyCrafting.endTime > -1):
		var currentTime = OS.get_unix_time()
		if (currentTime >= tradeskill.currentlyCrafting.endTime):
			tradeskill.readyToCollect = true
			
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
		
	staffedHeroNameAndSkill.text = tradeskill.hero.heroName + " skill level: " + str(tradeskill.hero.skillBlacksmithing)
		
func _update_ingredients():
	#called any time the user selects a recipe 
	recipe = tradeskill.selectedRecipe #make a local copy so we don't have to use a long reference
	
	recipeName.text = "Selected recipe: " + recipe.recipeName

	labelTime.text = str(util.format_time(recipe.craftingTime))
	if (recipe.noFail):
		labelFailNoFail.text = "No fail"
	else:
		labelFailNoFail.text = "Chance to fail"
	
	#every recipe has at least one ingredient
	#but some recipes let you pick what that ingredient actually is (ie: a sword for sharpening)
	#decorate the ingredient buttons accordingly 
	
	#determine which ingredients to display and whether the text is red or green 
	if (recipe.ingredient1): #if this quest has a fourth required component
		var ingredientName = staticData.items[str(recipe.ingredient1)]
		var quantityNeeded = recipe.ingredient1Quantity
		var playerHas = global.playerTradeskillItems[recipe.ingredient1].count
		#if you get an error "Invalid operands for 'int' and "String" in operator >=
		#check that this ingredient actually has a quantity defined in recipes data spreadsheet 
		ingredient1Display._render_stacked_item_with_total(ingredientName, quantityNeeded, playerHas)
		if (playerHas >= quantityNeeded):
			ingredient1Display._set_green()
		else:
			ingredient1Display._set_red()
	else:
		ingredient1Display._clear_fields()
		
	if (recipe.ingredient2): #if this quest has a fourth required component
		var ingredientName = staticData.items[str(recipe.ingredient2)]
		var quantityNeeded = recipe.ingredient2Quantity
		var playerHas = global.playerTradeskillItems[recipe.ingredient2].count
		ingredient2Display._render_stacked_item_with_total(ingredientName, quantityNeeded, playerHas)
		if (playerHas >= quantityNeeded):
			ingredient2Display._set_green()
		else:
			ingredient2Display._set_red()
	else:
		ingredient2Display._clear_fields()
		
	if (recipe.ingredient3): #if this quest has a fourth required component
		var ingredientName = staticData.items[str(recipe.ingredient3)]
		var quantityNeeded = recipe.ingredient3Quantity
		var playerHas = global.playerTradeskillItems[recipe.ingredient3].count
		ingredient3Display._render_stacked_item_with_total(ingredientName, quantityNeeded, playerHas)
		if (playerHas >= quantityNeeded):
			ingredient3Display._set_green()
		else:
			ingredient3Display._set_red()
	else:
		ingredient3Display._clear_fields()
		
	if (recipe.ingredient4): #if this quest has a fourth required component
		var ingredientName = staticData.items[str(recipe.ingredient4)]
		var quantityNeeded = recipe.ingredient4Quantity
		var playerHas = global.playerTradeskillItems[recipe.ingredient4].count
		ingredient4Display._render_stacked_item_with_total(ingredientName, quantityNeeded, playerHas)
		if (playerHas >= quantityNeeded):
			ingredient4Display._set_green()
		else:
			ingredient4Display._set_red()
	else:
		ingredient4Display._clear_fields()
		
	#results area
	if (!tradeskill.inProgress && !tradeskill.readyToCollect):
		print("NOT IN PROGRESS, NOT READY TO COLLECT")
		#not crafting anything (not inProgress), just browsng
		nowCrafting.text = "You will get: "
	
		if (recipe.ingredientWildcard):
			#this recipe requires the player to "choose" the result item 
			global.browsingForType = recipe.ingredientWildcard #contains the type, such as "blade" 
			if (tradeskill.wildcardItemOnDeck):
				#the player already picked an "on deck" wildcard item
				hasWildcardIngredient = true
				labelChoose.hide()
				resultItemBox._set_info_popup_buttons(true, false, "Return to vault")
				resultItemBox._render_tradeskill(global.tradeskills[global.currentMenu].wildcardItemOnDeck)
			else:
				hasWildcardIngredient = false
				resultItemBox._set_info_popup_buttons(true, false, "Choose")
				labelChoose.show()
				resultItemBox._clear_tradeskill()
		else:
			#this recipe doesn't require the player to pick an item to modify
			tradeskill.wildcardItemOnDeck = null
			hasWildcardIngredient = false
			labelChoose.hide()
		
		if (recipe.result == "computed"):
			labelComputed.show()
			labelComputed.text = "+" +str(recipe.statIncrease) + " " + str(recipe.statImproved)
			if (global.tradeskills[global.currentMenu].wildcardItemOnDeck):
				resultItemBox._render_tradeskill(global.tradeskills[global.currentMenu].wildcardItemOnDeck)
			else:
				resultItemBox._clear_tradeskill()
				
		elif (recipe.result):
			labelComputed.hide()
			resultItemBox._render_tradeskill(staticData.items[str(recipe.result)])
	elif (tradeskill.inProgress && !tradeskill.readyToCollect || tradeskill.inProgress && tradeskill.readyToCollect):
		labelChoose.hide()
		labelComputed.hide()
		
		var itemName = tradeskill.currentlyCrafting.name
		resultItemBox._render_tradeskill(staticData.items[itemName])
		
		if (tradeskill.currentlyCrafting.moddingAnItem):
			nowCrafting.text = "Now Crafting: Improved " + itemName
			labelComputed.show()
			labelComputed.text = "+" +str(tradeskill.currentlyCrafting.statIncrease) + " " + str(tradeskill.currentlyCrafting.statImproved)
		else:
			nowCrafting.text = "Now Crafting: " + itemName
		
			
func _process(delta):
	#Displays how much time is left on the active recipe 
	if (tradeskill.inProgress && !tradeskill.readyToCollect):
		var currentTime = OS.get_unix_time()
		if (currentTime >= tradeskill.currentlyCrafting.endTime):
			tradeskill.readyToCollect = true
			
		combineButton.set_text(util.format_time(tradeskill.currentlyCrafting.endTime - OS.get_unix_time()))
				
		#combineButton.set_text(util.format_time(tradeskill.timer.time_left))
		#to get the percent, we need to know how long this recipe takes and how much time has elapsed
		#divide time elapsed by time needed to complete
		
		#progressBar.set_value(100 * ((tradeskill.currentlyCrafting.totalTimeToFinish - tradeskill.timer.time_left) / tradeskill.currentlyCrafting.totalTimeToFinish))
		
		var progressBarValue = (100 * (tradeskill.currentlyCrafting.totalTimeToFinish - (tradeskill.currentlyCrafting.endTime - OS.get_unix_time())) / tradeskill.currentlyCrafting.totalTimeToFinish)
		#General formula:
		#100 * ((total time to finish - timer time left) / total time to finish)
		#60 - 40 / 60 =    20 / 60    = .33    x 100 = 33 

		progressBar.set_value(progressBarValue)
	
	elif (tradeskill.inProgress && tradeskill.readyToCollect):
		combineButton.set_text("COLLECT!")
		combineButton.add_color_override("font_color", colors.yellow) #239, 233, 64 yellow
		progressBar.set_value(100)
	else:
		combineButton.set_text("COMBINE")
		combineButton.add_color_override("font_color", colors.white) #white

func _open_collect_result_popup():
	#determine if we get a skillup and show or hide skillup text accordingly 
	var skillPath = "skill"+tradeskill.displayName
	if (util.determine_if_skill_up_happens(tradeskill.hero[skillPath], tradeskill.selectedRecipe.trivial)): #pass current skill, pass trivial level
		tradeskill.hero[skillPath] += 1
		finishedItemPopup._set_skill_up(tradeskill.hero, tradeskill.displayName)
		_update_hero_skill_display()
	else:
		finishedItemPopup._show_skill_up_text(false)
		
	finishedItemPopup._set_icon(staticData.items[str(tradeskill.currentlyCrafting.name)].icon)
	
	#since we don't actually create the item until it is collected,
	#we can't use its final name yet. This "fakes" it - 
	var itemNameStr = ""
	if (tradeskill.currentlyCrafting.moddingAnItem):
		itemNameStr = "Improved " + tradeskill.currentlyCrafting.name
	else:
		itemNameStr = tradeskill.currentlyCrafting.name
	
	finishedItemPopup._set_item_name(itemNameStr)
	finishedItemPopup.popup()

func tradeskillItem_callback():
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

	progressBar.set_value(0)
	#tradeskill.timer.stop()
	tradeskill.wildcardItemOnDeck = null
	tradeskill.inProgress = false
	tradeskill.readyToCollect = false
	tradeskill.currentlyCrafting = {
        "moddingAnItem":false,
        "wildcardItem":null,
        "name":"",
        "statImproved":"",
        "statIncrease":"",
        "totalTimeToFinish":"",
        "endTime":-1
    }
	#tradeskill.currentlyCrafting.moddingAnItem = false
	#tradeskill.currentlyCrafting.wildcardItem = null
	#tradeskill.currentlyCrafting.statImproved = null
	#tradeskill.currentlyCrafting.statIncrease = null
	_update_ingredients()
	
func _ingredient_check():
	var readyToCombine = true
	if (recipe.ingredient1 && global.playerTradeskillItems[recipe.ingredient1].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient2 && global.playerTradeskillItems[recipe.ingredient2].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient3 && global.playerTradeskillItems[recipe.ingredient3].count == 0):
		readyToCombine = false
		
	if (recipe.ingredient4 && global.playerTradeskillItems[recipe.ingredient4].count == 0):
		readyToCombine = false
		
	if (recipe.ingredientWildcard && !tradeskill.wildcardItemOnDeck):
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
				if (global.playerTradeskillItems[recipe.ingredient1].consumable):
					global.playerTradeskillItems[recipe.ingredient1].count -= 1
					#util.remove_item_guild_by_name(recipe.ingredient1)
				
			if (recipe.ingredient2):
				if (global.playerTradeskillItems[recipe.ingredient2].consumable):
					global.playerTradeskillItems[recipe.ingredient2].count -= 1
			
			if (recipe.ingredient3):
				if (global.playerTradeskillItems[recipe.ingredient3].consumable):
					global.playerTradeskillItems[recipe.ingredient3].count -= 1
				
			if (recipe.ingredient4):
				if (global.playerTradeskillItems[recipe.ingredient4].consumable):
					global.playerTradeskillItems[recipe.ingredient4].count -= 1
					
			if (recipe.ingredientWildcard):
				tradeskill.currentlyCrafting.moddingAnItem = true
				tradeskill.currentlyCrafting.wildcardItem = tradeskill.wildcardItemOnDeck
				tradeskill.wildcardItemOnDeck = null
				
			#global._begin_tradeskill_timer(tradeskill.selectedRecipe.craftingTime)
	
			#set the currentlyCrafting item (this won't change as user browses recipes list and serves to "remember" the item being worked on)
			if (tradeskill.selectedRecipe.result != "computed"):
				tradeskill.currentlyCrafting.name = tradeskill.selectedRecipe.result
			elif (tradeskill.selectedRecipe.result == "computed"):
				tradeskill.currentlyCrafting.name = tradeskill.currentlyCrafting.wildcardItem.name
				tradeskill.currentlyCrafting.statImproved = recipe.statImproved
				tradeskill.currentlyCrafting.statIncrease = recipe.statIncrease
			else:
				print("crafting.gd - Unknown result type")
				
			tradeskill.currentlyCrafting.totalTimeToFinish = recipe.craftingTime #make record of how long this recipe needs to finish 
			tradeskill.inProgress = true
			tradeskill.readyToCollect = false
			tradeskill.currentlyCrafting.endTime = OS.get_unix_time() + recipe.craftingTime
			
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
		
func _on_button_back_pressed():
	if (tradeskill.wildcardItemOnDeck):
		#putting an item "on deck" to mod but not actually starting the
		#crafting promise should return that on deck item to the guild vault
		util.remove_item_tradeskill()
		
		#util.give_item_guild(tradeskill.wildcardItemOnDeck)
		#tradeskill.wildcardItemOnDeck = null
	
	get_tree().change_scene("res://main.tscn")
