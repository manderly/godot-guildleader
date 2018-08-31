extends Node2D

var itemsInCurrentRow = 0
var itemsPerRow = 6
var rowsToDraw = 0 #calculate this based on vault space 
var buttonArray = []

func _ready():
	#display inventory size and capacity
	$field_guildInventoryCapacity.text = str(global.guildItems.size()) + "/" + str(global.vaultSpace)
	_position_vault_buttons()
	
func _position_vault_buttons():
	#this method handles the STRUCTURE of the buttons
	#it places the empty buttons in the correct hboxes
	#use _draw_vault_items() to put icons and data into buttons
	rowsToDraw = global.vaultSpace / 6  #example: if the player is entitled to 24 spaces, then 24 / 6 = 4 rows
	
	#draw all the rows, and if there happens to be an item in the corresponding guildItems array, add its data 
	for i in range(global.vaultSpace):
		#futile attempt to get buttons to all save their indexes 
		#var itemButton = preload("res://menus/itemButton.tscn").new()
		var itemButton = preload("res://menus/itemButton.tscn").instance()
		itemButton._set_vault_index(i)
		itemButton.connect("updateSourceButtonArt", self, "_draw_vault_items")
		$centerContainer/grid.add_child(itemButton)
		buttonArray.append(itemButton)
		
	_draw_vault_items()
	
func _draw_vault_items():
		#now we pair each physical button with data from global.guildItems array 
		#grab each button from buttonArray and "decorate" it 
		var currentButton = null
		for i in range(buttonArray.size()):
			currentButton = buttonArray[i]
			if (global.guildItems[i]):
				if (global.guildItems[i].slot):
					#print("global.guildItems has an item in this index (" + str(i) + ") it is: " + global.guildItems[i].name)
					currentButton._set_label(global.guildItems[i].slot)
					currentButton._set_icon(global.guildItems[i].icon)
					currentButton._set_data(global.guildItems[i])
			else:
				currentButton._clear_label()
				currentButton._clear_icon()
				currentButton._clear_data()
				#keep vault index intact 
	
func _on_button_back_pressed():
	if (global.currentMenu == "vaultViaHeroPage"):
		global.currentMenu = "heroPage"
		get_tree().change_scene("res://menus/heroPage.tscn")
	else:
		get_tree().change_scene("res://main.tscn")
	
func _on_button_quickSort_pressed():
	#sort the array such that nulls are last 
	var start = 0
	var end = global.vaultSpace - 1
	var tmp = []
	tmp.resize(global.vaultSpace)
	
	global.logger(self, "guild items size is now:" + str(global.guildItems.size()))
	for i in range(global.vaultSpace):
		if (global.guildItems[i] != null):
			tmp[start] = global.guildItems[i]
			start += 1
		else:
			tmp[end] = global.guildItems[i]
			end -= 1
	
	for i in range(global.vaultSpace):
		global.guildItems[i] = tmp[i]
	
	_draw_vault_items()
