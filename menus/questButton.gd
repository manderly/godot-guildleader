extends Node2D
#questButton.gd 

var questData = null
signal updateQuest

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_quest_data(data):
	$questButton.text = data.name
	#todo: color the button text according to difficulty of quest compared to guild's prestige level 
	#look at crafting trivials for example when it's time to implement 
	questData = data
	
func _on_questButton_pressed():
	global.selectedQuestID = questData.questId
	emit_signal("updateQuest")