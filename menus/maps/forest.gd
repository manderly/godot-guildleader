extends Node2D

func _ready():
	$campNode1._set_data("camp_forest01")
	$campNode2._set_data("camp_forest02")
	$campNode3._set_data("camp_forest03")

	$harvestingNode1._set_data("harvesting_forest_copperOre")