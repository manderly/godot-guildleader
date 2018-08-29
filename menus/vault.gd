extends Node2D

var itemsInCurrentRow = 0
var itemsPerRow = 6
var rowsToDraw = 0 #calculate this based on vault space 
var currentRow = 1
var buttonArray = []

func _ready():
	#hbox.add_constant_override("separation", 4)
	
	#display inventory size and capacity
	$field_guildInventoryCapacity.text = str(global.guildItems.size()) + "/" + str(global.vaultSpace)
	buttonArray.resize(global.vaultSpace)
	
	_draw_vault_items()
	
func updateSourceButtonArt_callback():
	#print("redrawing THIS button: ")
	#print(global.lastItemButtonClicked)
	var swappedItem = global.guildItems[global.swapItemSourceIdx]
	print(swappedItem)
	if (swappedItem):
		global.lastItemButtonClicked._set_label(swappedItem.slot)
		global.lastItemButtonClicked._set_icon(swappedItem.icon)
		global.lastItemButtonClicked._set_data(swappedItem)
	else:
		global.lastItemButtonClicked._clear_label()
		global.lastItemButtonClicked._clear_icon()
		global.lastItemButtonClicked._clear_data()
	global.lastItemButtonClicked = null
	
func _draw_vault_items():
	#calculate how many rows to draw
	rowsToDraw = global.vaultSpace / 6  #example: if the player is entitled to 24 spaces, then 24 / 6 = 4 rows
	
	#draw all the rows, and if there happens to be an item in the corresponding guildItems array, add its data 
	for i in range(global.vaultSpace):
		var itemButton = preload("res://menus/itemButton.tscn").instance()
		itemButton._set_vault_index(i)
		itemButton.connect("updateSourceButtonArt", self, "updateSourceButtonArt_callback")
		#it'll crash if it tries to look in an index that doesn't exist
		#and it's quite possible the user is entitled to loads of spaces but only has a few items 
		if (i < global.guildItems.size()): 
			if (global.guildItems[i]):
				itemButton._set_label(global.guildItems[i]["slot"])
				itemButton._set_icon(global.guildItems[i]["icon"])
				itemButton._set_data(global.guildItems[i])
			
		if (itemsInCurrentRow == itemsPerRow):
			currentRow += 1
			itemsInCurrentRow = 0

		#finally, add this button as a child to the correct hbox 
		if (currentRow == 1):
			$hbox1.add_child(itemButton)
		elif (currentRow == 2):
			$hbox2.add_child(itemButton)
		elif (currentRow == 3):
			$hbox3.add_child(itemButton)
		elif (currentRow == 4):
			$hbox4.add_child(itemButton)
		elif (currentRow == 5):
			$hbox5.add_child(itemButton)
		
		itemsInCurrentRow += 1
		buttonArray.append(itemButton)
	
func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
	
func _on_button_quickSort_pressed():
	#sort the array such that nulls are last 
	var start = 0
	var end = global.guildItems.size() - 1
	var tmp = []
	tmp.resize(global.vaultSpace)
	
	for i in range(global.guildItems.size()):
		if (global.guildItems[i] != null):
			tmp[start] = global.guildItems[i]
			start += 1
		else:
			tmp[end] = global.guildItems[i]
			end -= 1
	
	for i in range(global.guildItems.size()):
		global.guildItems[i] = tmp[i]
	
	#redraw the buttons
	var currentButton = null
	for i in range(buttonArray.size()):
		currentButton = buttonArray[i]
		if (currentButton):
			print(currentButton)
			print("i: " + str(i))
			if (global.guildItems[i]):
				print(global.guildItems[i])
				#currentButton._set_label(global.guildItems[i].name)
				#currentButton._set_icon(global.guildItems[i].icon)
				#currentButton._set_data(global.guildItems[i])
