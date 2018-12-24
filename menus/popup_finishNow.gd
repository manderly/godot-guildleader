extends ConfirmationDialog
#to use: onready var finishNowPopup = preload("res://menus/popup_finishNow.tscn").instance() 
#complete example in crafting.gd

var finishingThis = ""
var hcCost = 0
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _set_data(whatToFinish, costToFinish, optionalString=""):
	#save these as local vars so the confirmation dialog can access them 
	print("popup_finishNow.gd - cost to finish " + whatToFinish + ": " + str(costToFinish))
	finishingThis = whatToFinish
	hcCost = costToFinish
	if (optionalString != ""):
		optionalString = optionalString + "\n"
	dialog_text = optionalString + "Finish now for " + str(hcCost) + " Chrono?"

func _on_ConfirmationDialog_confirmed():
	print(finishingThis)
	if (global.hardCurrency > 0):
		global.hardCurrency -= hcCost
		if (finishingThis == "Tradeskill"):
			global.tradeskills[global.currentMenu].readyToCollect = true
			global.tradeskills[global.currentMenu].currentlyCrafting.endTime = OS.get_unix_time()
		elif (finishingThis == "Harvesting"):
			global.activeHarvestingData[global.selectedHarvestingID].readyToCollect = true
			global.activeHarvestingData[global.selectedHarvestingID].endTime = OS.get_unix_time()
		elif (finishingThis == "Camp"):
			global.activeCampData[global.selectedCampID].readyToCollect = true
			global.activeCampData[global.selectedCampID].endTime = OS.get_unix_time()
		elif (finishingThis == "Training"):
			global.training[global.selectedHero.staffedToID].readyToCollect = true
			global.training[global.selectedHero.staffedToID].endTime = OS.get_unix_time()
	else:
		print("popup_finishNow.gd: INSUFFICIENT CHRONO")
