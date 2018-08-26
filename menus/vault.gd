extends Node2D

func _ready():
	$hbox.add_constant_override("separation", 4)
	print("GUILD INVENTORY:")
	for i in range(global.guildItems.size()):
		var itemButton = preload("res://menus/vault_itemButton.tscn").instance()
		itemButton._set_icon(global.guildItems[i]["icon"])
		itemButton._set_data(global.guildItems[i])
		#print(global.guildItems[i]["icon"])
		$hbox.add_child(itemButton)
		print(global.guildItems[i])

