extends Node2D
#coast.gd

func _ready():
	global.returnToMap = "coast"
	$questMarker1._set_data("camp_coast01")
	$questMarker2._set_data("camp_coast02")
	$questMarker3._set_data("camp_coast03")
	$questMarker4._set_data("camp_coast04")
	$questMarker5._set_data("camp_coast05")
	$questMarker6._set_data("camp_coast06")
	$questMarker7._set_data("camp_coast07")
	$questMarker8._set_data("camp_coast08")

func _on_button_back_pressed():
	get_tree().change_scene("res://menus/maps/worldmap.tscn")
