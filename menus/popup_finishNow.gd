extends ConfirmationDialog

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _set_data(whatToFinish, costToFinish):
	#save these as local vars so the confirmation dialog can access them 
	print("popup_finishNow.gd - cost to finish " + whatToFinish + ": " + str(costToFinish))
	pass

func _on_ConfirmationDialog_confirmed():
	global.blacksmithingReadyToCollect = true
	pass # replace with function body
