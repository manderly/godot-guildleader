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
	dialog_text = optionalString + "Finish now for " + str(hcCost) + " diamonds?"

func _on_ConfirmationDialog_confirmed():
	print(finishingThis)
	if (global.hardCurrency > 0):
		global.hardCurrency -= hcCost
		if (finishingThis == "Tradeskill"):
			global.tradeskills[global.currentMenu].readyToCollect = true
			global.tradeskills[global.currentMenu].timer.stop()
		elif (finishingThis == "Harvesting"):
			global.activeHarvestingData[global.selectedHarvestingID].readyToCollect = true
			global.activeHarvestingData[global.selectedHarvestingID].timer.stop()
		elif (finishingThis == "Camp"):
			global.activeCampData[global.selectedCampID].readyToCollect = true
			global.activeCampData[global.selectedCampID].timer.stop()
	else:
		print("popup_finishNow.gd: INSUFFICIENT DIAMONDS")
