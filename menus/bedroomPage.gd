extends Node2D
#bedroomPage.gd

var bedroomEquipmentSlots = ["bed0", "bed1", "rug", "decor"]
var bedroomEquipmentSlotNames = ["Bed 1", "Bed 2", "Rug", "Decor"]

#containers
onready var inventoryGrid = $CenterContainer/VBoxContainer/centerContainer/grid
onready var bedroomName = $CenterContainer/VBoxContainer/HBox_Hero/VBox_Center/field_bedroomName

# Called when the node enters the scene tree for the first time.
func _ready():
	bedroomName.text = global.selectedBedroom
	
	#Create the room's inventory buttons
	var slot = null
	for i in range(bedroomEquipmentSlots.size()):
		slot = bedroomEquipmentSlots[i]
		
		var bedroomInventoryButton = preload("res://menus/itemButton.tscn").instance()
		bedroomInventoryButton._set_label(bedroomEquipmentSlotNames[i])
		bedroomInventoryButton._set_slot(bedroomEquipmentSlots[i])
		bedroomInventoryButton.add_to_group("BedroomInventoryButtons")
		
		#show buttons and give the option to put item in vault
		bedroomInventoryButton._set_info_popup_buttons(true, true, "Put in vault")
			
		#only set icon if the bedroom actually has an item in this slot, otherwise empty
		#this looks in the selected bedroom's inventory object for something called "mainHand" or "offHand" etc 
		if (global.bedrooms[global.selectedBedroom]["inventory"][slot] != null):
			bedroomInventoryButton._render_bedroom_page(global.bedrooms[global.selectedBedroom]["inventory"][slot])
	
		inventoryGrid.add_child(bedroomInventoryButton)