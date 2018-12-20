extends Node

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_button_forest_pressed():
	get_tree().change_scene("res://menus/maps/forest.tscn");
	
func _on_button_coast_pressed():
	get_tree().change_scene("res://menus/maps/coast.tscn");

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_button_falls_pressed():
	get_tree().change_scene("res://menus/maps/falls.tscn");
