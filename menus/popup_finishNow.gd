extends ConfirmationDialog

var hcCost = 0
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _set_data(whatToFinish, costToFinish):
	#save these as local vars so the confirmation dialog can access them 
	print("popup_finishNow.gd - cost to finish " + whatToFinish + ": " + str(costToFinish))
	hcCost = costToFinish
	dialog_text = "Finish now for " + str(hcCost) + " diamonds?"

func _on_ConfirmationDialog_confirmed():
	if (global.hardCurrency > 0):
		global.hardCurrency -= hcCost
		global.tradeskills[global.currentMenu].readyToCollect = true
		global.tradeskills[global.currentMenu].timer.stop()
	else:
		print("popup_finishNow.gd: INSUFFICIENT DIAMONDS")
