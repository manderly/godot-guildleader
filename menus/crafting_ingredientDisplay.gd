extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _render_fields(ingredientData):
	$field_ingredientName.text = ingredientData.name
	$sprite_icon.texture = load("res://sprites/items/" + ingredientData.icon)
	
func _clear_fields():
	$field_ingredientName.text = ""
	$sprite_icon.texture = null
	
func _set_green():
	$field_ingredientName.add_color_override("font_color", Color(.062, .90, .054, 1)) #16,230,14,1 green
	
func _set_red():
	$field_ingredientName.add_color_override("font_color", Color(.94, .0078, .0078, 1)) #242,2,2,1 green