extends Node2D
var util = load("res://util.gd").new()

#recipeButton.gd
var recipeData = null
var crafterSkill = 0
signal updateRecipe

func _ready():
	pass

func set_recipe_data(data):
	$recipeButton.text = data.recipeName + " [" + str(data.trivial) + "]"
	#color the button text according to difficulty of recipe vs. crafter's skill level
	if (data.trivial < crafterSkill):
		#this recipe is beneath the crafter's skill level, make it white
		$recipeButton.add_color_override("font_color", Color(1, 1, 1, 1)) #white
	elif (data.trivial >= crafterSkill + 6):
		#this recipe is 6 or more above crafter's skill level, make it red
		$recipeButton.add_color_override("font_color", Color(.89, .176, .156, 1)) #(227,45,40) red
	elif (data.trivial > crafterSkill && data.trivial <= crafterSkill + 5):
		#this recipe is between 1 and 5 more than crafter's skill level, make it yellow
		$recipeButton.add_color_override("font_color", Color(.93, .913, .25, 1)) #239, 233, 64 yellow
	else:
		print("recipeButton.gd - don't know how to color this button")
		
	$recipeButton/field_timeToCreate.text = str(util.format_time(data.craftingTime))
	recipeData = data
	
func set_crafter_skill_level(level):
	crafterSkill = level

func _on_recipeButton_pressed():
	global.tradeskills[global.currentMenu].selectedRecipe = recipeData
	emit_signal("updateRecipe")
	