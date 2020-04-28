extends Node2D
#forest.gd 

func _ready():
	global.returnToMap = "res://menus/maps/forest.tscn"
	$campNode1._set_data("camp_forest01")
	$campNode2._set_data("camp_forest02")
	$campNode3._set_data("camp_forest03")
	$campNode4._set_data("camp_forest04")
	$campNode5._set_data("camp_forest05")
	$campNode6._set_data("camp_forest06")
	$campNode7._set_data("camp_forest07")

	$harvestingNode1._set_data("harvesting_forest_copperOre")
	$harvestingNode2._set_data("harvesting_forest_roughStone")
	$harvestingNode3._set_data("harvesting_forest_fish")
		
	#todo: hide/show the harvesting nodes on a timer
	#todo: randomize position of harvesting nodes 

func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/worldmap.tscn")