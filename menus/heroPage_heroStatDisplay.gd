extends HBoxContainer

func _ready():
	pass

func _update_fields(statName, value):
	$field_label.text = statName
	$field_value.text = str(value)
