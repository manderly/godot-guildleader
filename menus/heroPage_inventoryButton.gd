extends Button

onready var itemPopup = preload("res://menus/popup_itemInfo.tscn").instance()
var itemData = null

func _ready():
	#todo: use some math to center it 
	add_child(itemPopup)
	pass

func _set_label(inventorySlotName):
	$field_slotName.text = inventorySlotName

func _set_icon(filename):
	$sprite_itemIcon.texture = load("res://sprites/items/" + filename)

#item data comes in here
func _set_data(data):
	itemData = data

func _on_Button_pressed():
	#only show the item popup if there is an item, otherwise go to the vault 
	if (itemData):
		itemPopup._set_data(itemData)
		itemPopup.popup()
	else:  
		get_tree().change_scene("res://menus/vault.tscn")  #todo: filter by item type 
