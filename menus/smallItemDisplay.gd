extends Container
#smallItemDisplay.gd 

func _ready():
	pass

func _render_fields(ingredientData):
	$field_name.text = ingredientData.name
	$sprite_icon.texture = load("res://sprites/items/" + ingredientData.icon)
	if ("tint" in ingredientData):
		$sprite_icon.modulate = tints[ingredientData.tint]
		
func _display_in_vault(ingredientData):
	$field_name.text = ingredientData.name + " (" + str(ingredientData.count) + ")"
	_set_white()
	$sprite_icon.texture = load("res://sprites/items/" + ingredientData.icon)
	if ("tint" in ingredientData):
		if (ingredientData.tint != null):
			$sprite_icon.modulate = tints[ingredientData.tint]
	
func _render_stacked_item(itemData, quantity):
	$field_name.text = itemData.name + " x" + str(quantity)
	$sprite_icon.texture = load("res://sprites/items/" + itemData.icon)
	if ("tint" in itemData):
		if (itemData.tint != null):
			$sprite_icon.modulate = tints[itemData.tint]

func _render_stacked_item_with_total(itemData, quantity, total):
	if (total > 999):
		total = "999+"
	$field_name.text = itemData.name + " x" + str(quantity) + " (" + str(total) + ")"
	$sprite_icon.texture = load("res://sprites/items/" + itemData.icon)
	
func _clear_fields():
	$field_name.text = ""
	$sprite_icon.texture = null
	
func _set_green():
	$field_name.add_color_override("font_color", Color(.062, .90, .054, 1)) #16,230,14,1 green
	
func _set_red():
	$field_name.add_color_override("font_color", Color(.94, .0078, .0078, 1)) #242,2,2,1 green
	
func _set_white():
	$field_name.add_color_override("font_color", colors.white) #242,2,2,1 green