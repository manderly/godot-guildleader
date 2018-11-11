extends Node2D
#forest.gd 

func _ready():
	global.returnToMap = "forest"
	$campNode1._set_data("camp_forest01")
	$campNode2._set_data("camp_forest02")
	$campNode3._set_data("camp_forest03")

	$harvestingNode1._set_data("harvesting_forest_copperOre")
	$harvestingNode2._set_data("harvesting_forest_roughStone")
	
	#todo: hide/show the harvesting nodes on a timer
	#todo: randomize position of harvesting nodes 

func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/worldmap.tscn")