extends Node2D

var itemsInCurrentRow = 0
var itemsPerRow = 6
var rowsToDraw = 0 #calculate this based on vault space 
var currentRow = 1

func _ready():
	#hbox.add_constant_override("separation", 4)
	
	#display inventory size and capacity
	$field_guildInventoryCapacity.text = str(global.guildItems.size()) + "/" + str(global.vaultSpace)
	
	#calculate how many rows to draw
	rowsToDraw = global.vaultSpace / 6  #example: if the player is entitled to 24 spaces, then 24 / 6 = 4 rows
	
	#draw all the rows, and if there happens to be an item in the corresponding guildItems array, add its data 
	for i in range(global.vaultSpace):
		var itemButton = preload("res://menus/itemButton.tscn").instance()
		#it'll crash if it tries to look in an index that doesn't exist
		#and it's quite possible the user is entitled to loads of spaces but only has a few items 
		if (i < global.guildItems.size()): 
			if (global.guildItems[i]):
				itemButton._set_label(global.guildItems[i]["slot"])
				itemButton._set_icon(global.guildItems[i]["icon"])
				itemButton._set_data(global.guildItems[i])
				itemButton._set_vault_index(i)
		
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

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
