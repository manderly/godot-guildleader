extends CanvasLayer

signal start_game

func update_currency(sc, hc):
	var scField = $GUI/vbox_currencies/HBoxContainer/field_softCurrency
	scField.text = str(sc)
	
	var hcField = $GUI/vbox_currencies/HBoxContainer/field_hardCurrency
	hcField.text = str(hc)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
