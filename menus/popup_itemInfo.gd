extends WindowDialog
#popup_itemInfo.gd

var itemData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _set_data(data):
	itemData = data
	_populate_fields()
	
func _populate_fields():
	window_title = itemData.name
	$field_dps.text = "DPS:" + str(itemData.dps)
	if (!itemData.noDrop):
		$field_noDrop.text = "Tradeable"
	else:
		$field_noDrop.text = "NO DROP"
	$field_classes.text = "Classes: " + str(itemData.classRestriction)
	$field_itemStats.text = str(itemData)