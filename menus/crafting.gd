extends Node2D
onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance()
var util = load("res://util.gd").new()
var hasIngredient1 = false
var hasIngredient2 = false
var hasIngredient3 = false
var hasIngredient4 = false
var hasWildcardIngredient = false
var recipe = null

func _ready():
	add_child(finishNowPopup)
	if (global.currentMenu == "blacksmithing"):
		$field_craftingSkillName.text = "Blacksmithing"
		$field_description.text = "Combine fire and metal to create weapons, armor, and other tradeskill items from ores, metals, and other materials."
		#todo: maybe vbox is the wrong container type to use, since the auto spacing doesn't work in this case
		var yVal = 0
		for i in range(global.blacksmithingRecipes.size()):
			var recipeButton = preload("res://menus/recipeButton.tscn").instance()
			recipeButton.set_recipe_data(global.blacksmithingRecipes[i])
			recipeButton.set_position(Vector2(0, yVal))
			recipeButton.connect("updateBlacksmithingRecipe", self, "_update_blacksmithing_ingredients")
			$scroll/vbox.add_child(recipeButton)
			yVal += 32
		_update_blacksmithing_ingredients()
	elif (global.currentMenu == "tailoring"):
		$field_craftingSkillName.text = "Tailoring"
		$field_description.text = "Turn cloth and leather into useful items, such as robes, vests, and padding for plate armor made by blacksmiths."
	elif (global.currentMenu == "jewelcraft"):
		$field_craftingSkillName.text = "Jewelcraft"
		$field_description.text = "Bend metal and gemstones into sparkly jewelry with powerful stat bonuses."
	_update_hero_skill_display()
	
func _update_hero_skill_display():
	if (global.currentMenu == "blacksmithing"):
		$field_heroSkill.text = global.blacksmithHero.heroName + " skill level: " + str(global.blacksmithHero.skillBlacksmithing)
	elif (global.currentMenu == "tailoring"):
		$field_heroSkill.text = global.tailoringHero.heroName + " skill level: " + str(global.tailoringHero.skillTailoring)
	elif (global.currentMenu == "jewelcraft"):
		$field_heroSkill.text = global.jewelcraftHero.heroName + " skill level: " + str(global.jewelcraftHero.skillTailoring)
		
#todo: genericize to handle any recipe type
func _update_blacksmithing_ingredients():
	#called any time the user selects a recipe 
	recipe = global.selectedBlacksmithingRecipe #make a local copy so we don't have to use a long reference
	
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
		$recipeData/ingredientWildcard.show()
		$recipeData/ingredientWildcard._set_enabled()
		global.browsingForType = recipe.ingredientWildcard #contains the type, such as "blade" 
		if (global.blacksmithingWildcardItem):
			hasWildcardIngredient = true
			#if the user picked an item to be the wildcard item, show it here 
			$recipeData/label_choose.hide()
			$recipeData/ingredientWildcard._render_tradeskill(global.allGameItems[str(global.blacksmithingWildcardItem.name)])
		else:
			hasWildcardIngredient = false
			$recipeData/label_choose.show()
			$recipeData/ingredientWildcard._clear_tradeskill()
	else:
		global.blacksmithingWildcardItem = null
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
	if (global.blacksmithingInProgress && !global.blacksmithingReadyToCollect):
		$button_combine.set_text(util.format_time(global.blacksmithingTimer.time_left))
	elif (global.blacksmithingInProgress && global.blacksmithingReadyToCollect):
		$button_combine.set_text("COLLECT!")
		$button_combine.add_color_override("font_color", Color(.93, .913, .25, 1)) #239, 233, 64 yellow
	else:
		$button_combine.set_text("COMBINE")
		$button_combine.add_color_override("font_color", Color(1, 1, 1, 1)) #white
		
func _on_button_back_pressed():
	#todo: only clear it if it's not in use being upgraded
	global.blacksmithingWildcardItem = null
	get_tree().change_scene("res://main.tscn")

func _open_collect_result_popup():
	#todo: skill-up chance should use a more sophisticated formula
	#for now, it's just a 50/50 chance that you get a skill-up on combine
	
	#determine skillup and decorate the popup
	var skillUpRandom = randi()%2+1 #1-2
	if (skillUpRandom == 2):
		global.blacksmithHero.skillBlacksmithing += 1
		$finishedItem_dialog/elements/field_skillUp.text = global.blacksmithHero.heroName + " became better at blacksmithing! (" + str(global.blacksmithHero.skillBlacksmithing) + ")"
		$finishedItem_dialog/elements/field_skillUp.show()
		_update_hero_skill_display()
	else:
		$finishedItem_dialog/elements/field_skillUp.hide()
		
	#todo: crashes when in the sharpen weapon flow
	if (!global.blacksmithingWildcardItem): 
		$finishedItem_dialog/elements/sprite_icon.texture = load("res://sprites/items/" + global.allGameItems[str(recipe.result)].icon)
	else: 
		$finishedItem_dialog/elements/sprite_icon.texture = load("res://sprites/items/" + global.allGameItems[str(global.blacksmithingWildcardItem.name)].icon)
	$finishedItem_dialog/elements/field_itemName.text = global.selectedBlacksmithingRecipe.result
	$finishedItem_dialog.popup()

func _on_finishedItem_dialog_confirmed():
	#these things happen when the player dismisses the popup affirmatively
	#if the recipe is not "sharpening"
	if (!global.blacksmithingWildcardItem):
		#this is a "normal" recipe, not a wildcard item recipe
		util.give_item_guild(global.selectedBlacksmithingRecipe.result)
	else:
		#get the original item out of the all items dictionary
		var localItem = global.allGameItems[str(global.blacksmithingWildcardItem.name)]
		localItem.dps += 1 #hardcode to 1 for now 
		util.give_item_guild(localItem.name) #give the modified item to the guild inventory
	
	global.blacksmithingWildcardItem = null
	global.blacksmithingInProgress = false
	global.blacksmithingReadyToCollect = false
	
func _on_button_combine_pressed():
	if (!global.blacksmithingInProgress):
		#check if user has ingredients
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

		if (readyToCombine == false):
			$incomplete_dialog.popup() #tell the user they don't have all the ingredients
		else:
			#otherwise, start the timer and take ingredients from inventory
			global._begin_global_blacksmithing_timer(global.selectedBlacksmithingRecipe.craftingTime)
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
				if (global.allGameItems[str(global.blacksmithingWildcardItem.name)]):
					#this doesn't seem to be working, there's a duplicate sword generated 
					util.remove_item_guild(global.blacksmithingWildcardItem.name)
				
			_update_blacksmithing_ingredients()
				
	elif (global.blacksmithingInProgress && !global.blacksmithingReadyToCollect):
		#todo: cost logic for speeding up a recipe is based on trivial level of recipe and time left 
		finishNowPopup._set_data("blacksmithing", 2)
		finishNowPopup.popup()
	elif (global.blacksmithingInProgress && global.blacksmithingReadyToCollect):
		_open_collect_result_popup()
	else:
		print("crafting.gd - got in some weird state")


func _on_button_dismissHero_pressed():
	global.blacksmithHero.currentRoom = 1
	global.blacksmithHero = null
	get_tree().change_scene("res://main.tscn")
