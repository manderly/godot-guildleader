extends Node2D
#roster.gd
#makes a long list of every hero in the player's guild
#individual heroes can be clicked on to go to their hero page 
onready var field_prestige = $vbox_guildInfo/VBoxContainer/field_prestige
onready var field_founded = $vbox_guildInfo/vbox_bottomBox/field_founded

onready var field_guildMemberCount = $vbox_guildInfo/VBoxContainer/field_guildMemberCount
onready var field_guildName = $vbox_guildInfo/VBoxContainer/field_guildName

onready var field_tankCount = $vbox_guildInfo/vbox_bottomBox/HBoxContainer/vbox_classCounts/label_tankCount
onready var field_dpsCount = $vbox_guildInfo/vbox_bottomBox/HBoxContainer/vbox_classCounts/label_dpsCount
onready var field_supportCount = $vbox_guildInfo/vbox_bottomBox/HBoxContainer/vbox_classCounts/label_supportCount

func _ready():
	field_guildName.text = global.guildName
	field_guildMemberCount.text = "Members: " + str(global.guildRoster.size()) + "/" + str(global.guildCapacity)
	field_prestige.text = " Prestige: " + str(0)
	field_founded.text = "Founded: " + util.format_guild_creation_date(global.guildCreationDate)
	
	$confirm_rename_dialog.set_mode("guild")
	$confirm_rename_dialog.connect("guildNameUpdated", self, "_on_rename_guild_confirmed")
	$confirm_rename_dialog/LineEdit.connect("text_changed", self, "check_name_input") #, ["userInput"]
	
	var classRoles = {
		"tank":0,
		"dps":0,
		"support":0	
	}
	
	#draw a hero button for each hero in the roster
	for i in range(global.guildRoster.size()):
		classRoles[global.guildRoster[i].get_class_role()] += 1
		var heroButton = preload("res://menus/heroButton.tscn").instance()
		heroButton.set_hero_data(global.guildRoster[i])
		#heroButton.set_position(Vector2(buttonX, buttonY))
		$scroll_roster/vbox.add_child(heroButton)
	
	#update counts
	field_tankCount.text = "Tanks: " + str(classRoles["tank"])
	field_dpsCount.text = "DPS: " + str(classRoles["dps"])
	field_supportCount.text = "Support: " + str(classRoles["support"])

func check_name_input(userInput):
	#this is for GUILD NAMES
	#guild names can have spaces, multiple caps, and apostrophes 
	var regex = RegEx.new()
	regex.compile("[A-Za-z. '`]*")
	var result = regex.search(userInput)
	if (result):
		$confirm_rename_dialog.set_candidate_name(result.get_string())
	else:
		print("no result")
		
func _on_button_renameGuild_pressed():
	$confirm_rename_dialog.set_mode("guild")
	get_node("confirm_rename_dialog").popup()

func _on_rename_guild_confirmed():
	var newName = $confirm_rename_dialog/LineEdit.text
	print("roster.gd: Renamed guild to: " + newName)
	global.guildName = newName
	#redraw the name display field on the hero page with the new name
	field_guildName.text = global.guildName

func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")
