# popup_finishedItem.gd

extends AcceptDialog
#BE SURE TO DO THIS in _ready: add_child(finishedItemPopup)

onready var itemNameField = $elements/field_itemName
onready var skillUpField = $elements/field_skillUp

signal collectItem

func _ready():
	pass

func _set_item_name(itemNameStr):
	itemNameField.text = itemNameStr
	
func _set_skill_up(heroObj, skillNameStr):
	var skillPath = "skill"+skillNameStr #ex: hero.skillBlacksmithing
	skillUpField.text = heroObj.get_first_name() + " became better at " + skillNameStr + " (" + str(heroObj[skillPath]) + ")"
	_show_skill_up_text(true)

func _show_skill_up_text(showBool):
	if (showBool):
		skillUpField.show()
	else:
		skillUpField.hide()
	
func _set_icon(data):
	print(data)
	if ("icon" in data):
		$elements/sprite_icon.texture = load("res://sprites/items/" + data.icon)
	else:
		$elements/sprite_icon.texture = load("res://sprites/items/" + data)
	
	if ("tint" in data):
		if (data.tint != null):
			$elements/sprite_icon.modulate = tints[data.tint]
		else:
			$elements/sprite_icon.modulate = Color(1,1,1,1)

func _on_finishedItem_dialog_confirmed():
	emit_signal("collectItem")
