extends Button

var itemData = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _set_icon(filename):
	$sprite_itemIcon.texture = load("res://sprites/items/" + filename)

func _set_data(data):
	itemData = data

func _on_Button_pressed():
	print(itemData)
