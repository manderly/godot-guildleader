extends Node2D
#falls.gd 

func _ready():
	global.returnToMap = "res://menus/maps/falls.tscn"
	$campNode1._set_data("camp_falls01")
	$campNode2._set_data("camp_falls02")
	$campNode3._set_data("camp_falls03")
	$campNode4._set_data("camp_falls04")
	$campNode5._set_data("camp_falls05")
	$campNode6._set_data("camp_falls06")
	$campNode7._set_data("camp_falls07")

	$harvestingNode1._set_data("harvesting_falls_copperOre")
	$harvestingNode2._set_data("harvesting_falls_roughStone")
	
	#todo: hide/show the harvesting nodes on a timer
	#todo: randomize position of harvesting nodes 

func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/worldmap.tscn")