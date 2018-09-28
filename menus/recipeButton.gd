extends Node2D

var recipeData = null
signal updateBlacksmithingRecipe

func _ready():
	pass

func set_recipe_data(data):
	$recipeButton.text = data.recipeName + " (" + str(data.trivial) + ")"
	recipeData = data

func _on_recipeButton_pressed():
	if (global.currentMenu == "blacksmithing"):
		global.selectedBlacksmithingRecipe = recipeData
		print("recipeButton.gd: Changed active blacksmithing recipe to: " + str(global.selectedBlacksmithingRecipe))
		emit_signal("updateBlacksmithingRecipe")