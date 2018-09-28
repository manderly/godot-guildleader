extends Node2D


func _ready():
	if (global.currentMenu == "blacksmithing"):
		#doesn't work, doesn't catch signal 
		$recipeData.connect("updateBlacksmithingRecipe", self, "_update_blacksmithing_ingredients")
		
		$field_craftingSkillName.text = "Blacksmithing"
		$field_description.text = "Combine fire and metal to create weapons, armor, and other tradeskill items from ores, metals, and other materials."
		$field_heroSkill.text = global.blacksmithHero.heroName + " skill level: " + str(global.blacksmithHero.skillBlacksmithing)
		$field_craftingTime.text = str(global.selectedBlacksmithingRecipe.craftingTime)
		
		#todo: maybe vbox is the wrong container type to use, since the auto spacing doesn't work in this case
		var yVal = 0
		for i in range(global.blacksmithingRecipes.size()):
			var recipeButton = preload("res://menus/recipeButton.tscn").instance()
			recipeButton.set_recipe_data(global.blacksmithingRecipes[i])
			recipeButton.set_position(Vector2(0, yVal))
			$scroll/vbox.add_child(recipeButton)
			yVal += 32
			
		_update_blacksmithing_ingredients(global.selectedBlacksmithingRecipe)
		
	elif (global.currentMenu == "tailoring"):
		$field_craftingSkillName.text = "Tailoring"
		$field_description.text = "Turn cloth and leather into useful items, such as robes, vests, and padding for plate armor made by blacksmiths."
		$field_heroSkill.text = global.tailoringHero.heroName + " skill level: " + str(global.tailoringHero.skillTailoring)
	elif (global.currentMenu == "jewelcraft"):
		$field_craftingSkillName.text = "Jewelcraft"
		$field_description.text = "Bend metal and gemstones into sparkly jewelry with powerful stat bonuses."
		$field_heroSkill.text = global.jewelcraftHero.heroName + " skill level: " + str(global.jewelcraftHero.skillTailoring)

	
func _update_blacksmithing_ingredients(recipe):
	if (recipe.ingredient1):
		$recipeData/ingredient1._set_data(recipe.ingredient1)
	else:
		$recipeData/ingredient1._set_disabled()
		
	if (recipe.ingredient2):
		$recipeData/ingredient2._set_data(recipe.ingredient2)
	else:
		$recipeData/ingredient2._set_disabled()
		
	if (recipe.ingredient3):
		$recipeData/ingredient3._set_data(recipe.ingredient3)
	else:
		$recipeData/ingredient3._set_disabled()
		
	if (recipe.ingredient4):
		$recipeData/ingredient4._set_data(recipe.ingredient4)
	else:
		$recipeData/ingredient4._set_disabled()

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
