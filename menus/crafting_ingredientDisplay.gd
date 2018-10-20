extends Node2D

func _ready():
	pass

func _render_fields(ingredientData):
	$Container/field_name.text = ingredientData.name
	$Container/sprite_icon.texture = load("res://sprites/items/" + ingredientData.icon)
	
func _display_in_vault(ingredientData):
	$Container/field_name.text = str(ingredientData.count)
	_set_white()
	$Container/sprite_icon.texture = load("res://sprites/items/" + ingredientData.icon)
	
func _clear_fields():
	$Container/field_name.text = ""
	$Container/sprite_icon.texture = null
	
func _set_green():
	$Container/field_name.add_color_override("font_color", Color(.062, .90, .054, 1)) #16,230,14,1 green
	
func _set_red():
	$Container/field_name.add_color_override("font_color", Color(.94, .0078, .0078, 1)) #242,2,2,1 green
	
func _set_white():
	$Container/field_name.add_color_override("font_color", global.colorWhite) #242,2,2,1 green