extends AcceptDialog
#BE SURE TO DO THIS in _ready: add_child(finishedItemPopup)

onready var itemNameField = $elements/field_itemName
onready var skillUpField = $elements/field_skillUp

func _ready():
	pass

func _set_item_name(itemNameStr):
	itemNameField.text = itemNameStr
	
func _set_skill_up(heroObj, skillNameStr):
	var skillPath = "skill"+skillNameStr #ex: hero.skillBlacksmithing
	skillUpField.text = heroObj.heroName + " became better at " + skillNameStr + " (" + str(heroObj[skillPath]) + ")"
	_show_skill_up_text(true)

func _show_skill_up_text(showBool):
	if (showBool):
		skillUpField.show()
	else:
		skillUpField.hide()
	
func _set_icon(iconPath):
	$elements/sprite_icon.texture = load("res://sprites/items/" + iconPath)