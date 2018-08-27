extends Node2D

var itemsInCurrentRow = 0
var itemsPerRow = 6
var rowsToDraw = 0 #calculate this based on vault space 
var currentRow = 1


func _ready():
	#hbox.add_constant_override("separation", 4)
	print("GUILD INVENTORY:")
	
	#print inventory size and capacity
	$field_guildInventoryCapacity.text = str(global.guildItems.size()) + "/" + str(global.vaultSpace)
	
	#calculate how many rows to draw
	rowsToDraw = global.vaultSpace / 6  #example: if the player is entitled to 24 spaces, then 24 / 6 = 4 rows
	
	#first, draw all the active buttons
	for i in range(global.guildItems.size()):
		#if row is full, increase hbox number by 1 so items continue to draw one row lower
		if (itemsInCurrentRow == itemsPerRow):
			print("ROW FULL")
			currentRow += 1
			itemsInCurrentRow = 0
		
		var itemButton = preload("res://menus/vault_itemButton.tscn").instance()
		itemButton._set_icon(global.guildItems[i]["icon"])
		itemButton._set_data(global.guildItems[i])
		#print(global.guildItems[i]["icon"])
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
			
		print(global.guildItems[i])
		itemsInCurrentRow += 1
	
	#finish the row with empty boxes
	if (itemsInCurrentRow < itemsPerRow):
		for j in range(itemsInCurrentRow,itemsPerRow):
			var emptyButton = preload("res://menus/vault_itemButton.tscn").instance()
			if (currentRow == 1):
				$hbox1.add_child(emptyButton)
			elif (currentRow == 2):
				$hbox2.add_child(emptyButton)
			elif (currentRow == 3):
				$hbox3.add_child(emptyButton)
			elif (currentRow == 4):
				$hbox4.add_child(emptyButton)
			elif (currentRow == 5):
				$hbox5.add_child(emptyButton)

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
