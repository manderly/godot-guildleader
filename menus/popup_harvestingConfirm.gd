extends ConfirmationDialog

var nodeData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _set_data(data):
	nodeData = data
	_populate_fields()
	
func _populate_fields():
	window_title = nodeData.prizeItem1
	$VBoxContainer/HBoxContainer2/VBoxContainer/field_skillReq.text = "Harvesting skill required: " + str(nodeData.minSkill)
	$VBoxContainer/HBoxContainer2/VBoxContainer/field_duration.text = "Time to harvest: " + str(util.format_time(nodeData.timeToHarvest))
	$VBoxContainer/HBoxContainer2/VBoxContainer/field_yield.text = "Yield: " + str(nodeData.minQuantity) + " - " + str(nodeData.maxQuantity)
	$VBoxContainer/HBoxContainer2/TextureRect.texture = load("res://sprites/harvestNodes/" + nodeData.icon)
	if (nodeData.hero):
		$VBoxContainer/HBoxContainer/field_heroName.text = nodeData.hero.heroName
		$VBoxContainer/HBoxContainer/field_heroSkill.text = "Harvesting skill: " + str(nodeData.hero.skillHarvesting)
	else:
		$VBoxContainer/HBoxContainer/field_heroName.text = "SELECT A HERO"
		$VBoxContainer/HBoxContainer/field_heroSkill.text = ""

func _on_button_pickHero_pressed():
	global.currentMenu = "harvestPopup"
	global.selectedHarvestingID = nodeData.harvestingId
	get_tree().change_scene("res://menus/heroSelect.tscn")


func _on_ConfirmationDialog_confirmed():
	#start the timer on the appropriate harvest node object 
	#this button lets you either begin the harvesting or finish it early for HC
	#case 1: Begin harvesting (no quest active, nothing ready to collect)
	if (!nodeData.inProgress && !nodeData.readyToCollect):
		if (!nodeData.hero):
			#todo: need a popup here
			print("Not enough groupies yet")
		else:
			nodeData.hero.atHome = false
			#start the timer attached to the quest object over in global
			#it has to be done there, or else will be wiped from memory when we close this particular menu 
			global._begin_harvesting_timer(nodeData.timeToHarvest, nodeData.harvestingId);
	#case 2: harvest is active but not ready to collect 
	#todo: see if this can be done by just checking the status of the timer instead?
	elif (nodeData.inProgress && !nodeData.readyToCollect): #quest is ready to collect
		#todo: this is just set up on a global level for now, but ideally it'll be quest-specific 
		#get_node("quest_finish_now_dialog").popup()
		print("trigger finish now popup")
	elif (!nodeData.inProgress && nodeData.readyToCollect):
		#this is on the button, but really it should just kick you to the done screen automatically
		#get_tree().change_scene("res://menus/questComplete.tscn")
		print("collect harvest screen")
	else:
		#bug: we get into this state if we let the quest finish while sitting on the questConfirm page 
		print("harvestingConfirm.gd error - not sure what state we're in")
