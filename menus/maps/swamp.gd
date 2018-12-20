extends Node2D
#swamp.gd 

func _ready():
	global.returnToMap = "swamp"
	$campNode1._set_data("camp_swamp01")
	$campNode2._set_data("camp_swamp02")
	$campNode3._set_data("camp_swamp03")
	$campNode4._set_data("camp_swamp04")
	$campNode5._set_data("camp_swamp05")
	$campNode6._set_data("camp_swamp06")
	$campNode7._set_data("camp_swamp07")
	$campNode7._set_data("camp_swamp08")

	#$harvestingNode1._set_data("harvesting_falls_copperOre")
	#$harvestingNode2._set_data("harvesting_falls_roughStone")
	
	#todo: hide/show the harvesting nodes on a timer
	#todo: randomize position of harvesting nodes 

func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/worldmap.tscn")