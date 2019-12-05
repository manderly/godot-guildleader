extends Node

var heroGenerator = load("res://heroGenerator.gd").new()
var crafting = load("res://menus/crafting.gd").new()

# cannot use get_node with extends SceneTree, but must extend SceneTree or MainLoop 
#onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	tradeskillToMaxTest("Blacksmithing")
	tradeskillToMaxTest("Tailoring")
	tradeskillToMaxTest("Alchemy")
	tradeskillToMaxTest("Jewelcraft")
	tradeskillToMaxTest("Fletching")
	print("********Done********")


# script for "autoplaying" the game and determining if the balancing needs adjustment

# Tradeskill test
# Generate a hero and set him to work on a particular tradeskill
# Combine recipe after recipe
# Keep track of how many combines were needed to reach max skill
# Keep track of time spent 
# Note that all combines are successful, it's skillups that may or may not happen
	
func tradeskillToMaxTest(tradeskillStr):  # ex: Blacksmithing
	global.currentMenu = tradeskillStr.to_lower()  # ex: "blacksmithing"
	var tradeskill = global.tradeskills[global.currentMenu]
	
	var combineTracker = {}
	var ingredientTracker = {}
	
	print("********TRADESKILL TEST: " + tradeskillStr + "********")
	var classes = ["Wizard", "Rogue", "Warrior", "Cleric", "Ranger"]
	
	# make a level 1 hero with a randomly chosen class
	heroGenerator.generate(global.guildRoster, classes[randi()%len(classes)])
	var hero = global.guildRoster[0]
	# make that hero work on a randomly chosen tradeskill
	# todo: pass tradeskill in as param
	hero.staffedTo = tradeskillStr
	
	# assign to this tradeskill in the global object
	global.tradeskills[tradeskillStr.to_lower()].hero = hero
	
	# start crafting!
	var attempts = 0
	var timeSpent = 0
	var skillups = 0
	var loops = 0
	var crafterSkill = hero["skill"+tradeskillStr]
	
	while (hero["skill"+tradeskillStr] < 300 and attempts < 500 and loops < 500):
		loops+=1
		# pick a recipe, stopping on the first one that isn't trivial 
		# create that one over and over until it is trivial 
		for i in range(tradeskill.recipes.size()):
			var recipe = tradeskill.recipes[i]
			
			global.tradeskills[global.currentMenu].selectedRecipe = recipe
			while (hero["skill"+tradeskillStr] < recipe.trivial):
				# log this recipe
				
				if (combineTracker.has(recipe.recipeName)):
					combineTracker[recipe.recipeName]+=1
				else:
					combineTracker[recipe.recipeName]=1
				# log its ingredients
				
				if (recipe.ingredient1):
					if (ingredientTracker.has(recipe.ingredient1)):
						if (typeof(recipe.ingredient1Quantity) == TYPE_NIL):
							print(recipe.ingredient1 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient1]+=recipe.ingredient1Quantity
					else:
						if (typeof(recipe.ingredient1Quantity) == TYPE_NIL):
							print(recipe.ingredient1 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient1]=recipe.ingredient1Quantity
				
				if (recipe.ingredient2):
					if (ingredientTracker.has(recipe.ingredient2)):
						if (typeof(recipe.ingredient2Quantity) == TYPE_NIL):
							print(recipe.ingredient2 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient2]+=recipe.ingredient2Quantity
					else:
						if (typeof(recipe.ingredient2Quantity) == TYPE_NIL):
							print(recipe.ingredient2 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient2]=recipe.ingredient2Quantity
				
				if (recipe.ingredient3):
					if (ingredientTracker.has(recipe.ingredient3)):
						if (typeof(recipe.ingredient3Quantity) == TYPE_NIL):
							print(recipe.ingredient3 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient3]+=recipe.ingredient3Quantity
					else:
						if (typeof(recipe.ingredient3Quantity) == TYPE_NIL):
							print(recipe.ingredient3 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient3]=recipe.ingredient3Quantity
					
				if (recipe.ingredient4):
					if (ingredientTracker.has(recipe.ingredient4)):
						if (typeof(recipe.ingredient4Quantity) == TYPE_NIL):
							print(recipe.ingredient4 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient4]+=recipe.ingredient4Quantity
					else:
						if (typeof(recipe.ingredient4Quantity) == TYPE_NIL):
							print(recipe.ingredient4 + " quantity not set!")
						else:
							ingredientTracker[recipe.ingredient4]=recipe.ingredient4Quantity

				# note we don't actually have to do any combining, we're just evaluating
				# the rate at which the hero skills up given the formula as implemented 
				attempts+=1
				timeSpent+=recipe.craftingTime
				
				# whether the hero skills up or not is calculated in this crafting method
				if (crafting.tradeskill_skill_up("skill"+tradeskill.displayName)):
					skillups+=1
		loops+=1
	if (loops >= 100):
		print("Reached " + str(loops) + " loops")
		
	var hours = (timeSpent/60)/60
	
	print(hero.get_first_name() + " maxxed out at skill level " + str(hero["skill"+tradeskillStr]))
	print("Attempts: " + str(attempts) + " Skillups: " + str(skillups))
	print("Time spent crafting " + str(hours) + " hours")
	print("Combines:")
	var recipeNames = combineTracker.keys()
	var recipeQuantities = combineTracker.values()
	for i in range(recipeNames.size()):
		print (recipeNames[i] + ": " + str(recipeQuantities[i]))
	
	print("Ingredients used:")
	var ingredientNames = ingredientTracker.keys()
	var ingredientQuantities = ingredientTracker.values()
	for i in range(ingredientNames.size()):
		print (ingredientNames[i] + ": " + str(ingredientQuantities[i]))
		
		
		