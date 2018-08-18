extends Node2D

func _ready():
	populate_fields(global.selectedHero)
	#for each inventory slot, create a heroPage_inventoryButton instance and place it in a row
	var buttonX = 0
	var buttonY = 100
	
	for i in range(global.heroInventorySlots.size()):
		print(global.heroInventorySlots[i])
		var heroInventoryButton = preload("res://menus/heroPage_inventoryButton.tscn").instance()
		heroInventoryButton.set_label(global.heroInventorySlots[i])
		heroInventoryButton.set_position(Vector2(buttonX, buttonY))
		if (i < 4):
			$hbox_items.add_child(heroInventoryButton)
		else:
			$hbox_items2.add_child(heroInventoryButton)
		#todo: later, expand this to show the actual item owned by this hero for this slot 
	
func populate_fields(data):
	$field_heroName.text = data.heroName
	$field_levelAndClass.text = str(data.heroLevel) + " " + data.heroClass
	$field_xp.text = "XP: " + str(data.heroXp) + "/" + str(global.levelXpData[data.heroLevel].total)
	$field_hp.text = str(data.heroHp)
	$field_mana.text = str(data.heroMana)

func _on_button_train_pressed():
	if (global.selectedHero.heroXp == global.levelXpData[global.selectedHero.heroLevel].total):
		print("Training this hero to next level")
		#todo: this should be on a timer and the hero is unavailable while training
		#also, only one hero can train up at a time 
		global.selectedHero.heroXp = 0
		global.selectedHero.heroLevel += 1
	else: 
		print("Need more xp - or pay diamonds to level up now!")


func _on_button_back_pressed():
	get_tree().change_scene("res://menus/roster.tscn")
