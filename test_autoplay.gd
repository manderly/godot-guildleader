extends Node

var heroGenerator = load("res://heroGenerator.gd").new()
var crafting = load("res://menus/crafting.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
	
	var tracker = {}
	
	print("TRADESKILL TEST: " + tradeskillStr)
	var classes = ["Wizard", "Rogue", "Warrior", "Cleric", "Ranger"]
	
	# make a level 1 hero with a randomly chosen class
	heroGenerator.generate(global.guildRoster, classes[randi()%len(classes)])
	var hero = global.guildRoster[0]
	# make that hero work on a randomly chosen tradeskill
	# todo: pass tradeskill in as param
	hero.staffedTo = tradeskillStr

	# verify the hero 
	# where I left off - it's a kinematic body, not an object with data 
	print(hero)
	
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
				if (tracker.has(recipe.recipeName)):
					tracker[recipe.recipeName]+=1
				else:
					tracker[recipe.recipeName]=0
				#print("Crafting this: " + recipe.recipeName + " [trivial: " + str(recipe.trivial) + "]")
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
		
	print(hero.heroFirstName + " maxxed out at skill level " + str(hero["skill"+tradeskillStr]))
	print("Attempts: " + str(attempts) + " Skillups: " + str(skillups))
	print("Time spent crafting " + str(hours) + " hours")
	print(tracker)