extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
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
