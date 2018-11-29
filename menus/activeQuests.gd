extends Node2D

var quest = null

onready var questScrollList = $MarginContainer/CenterContainer/VBoxContainer/scroll/vbox
onready var field_questName = $MarginContainer/CenterContainer/VBoxContainer/field_questName
onready var field_questDescription = $MarginContainer/CenterContainer/VBoxContainer/field_questDescription
onready var prizeBox = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer2/prizeBox1

onready var component1Display = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/vbox_left/component1
onready var component2Display = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/vbox_left/component2
onready var component3Display = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/vbox_right/component3
onready var component4Display = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/vbox_right/component4

func _ready():
	var yVal = 0
	for quest in global.activeQuests:
		var questButton = preload("res://menus/questButton.tscn").instance()
		#questButton.set_crafter_skill_level(tradeskill.hero.skillBlacksmithing) #todo: fix 
		questButton.set_quest_data(quest)
		questButton.set_position(Vector2(0, yVal))
		questButton.connect("updateQuest", self, "_change_displayed_quest")
		questScrollList.add_child(questButton)
		yVal += 40
	_change_displayed_quest()


func _change_displayed_quest():
	#coded with the expectation that every quest gives exactly 1 prize item (and not 0 or 2)
	quest = staticData.allQuestData[global.selectedQuestID] #local copy 
	field_questName.text = quest.name
	field_questDescription.text = quest.text
	var itemData = staticData.allItemData[str(quest.prizeItem1)]
	prizeBox._render_quest_prize(itemData)
	_update_components_display()
	
func _update_components_display():
	#determine which ingredients to display and whether the text is red or green
	if (quest.reqItem1): #if this quest has a first required component
		component1Display._render_stacked_item(staticData.allItemData[str(quest.reqItem1)], quest.reqItem1Quantity) #pass: itemData, item count 
		if (global.playerQuestItems[quest.reqItem1].count >= quest.reqItem1Quantity): #and we have it in the quest items dictionary
			component1Display._set_green()
		else:
			component1Display._set_red()
	else:
		component1Display._clear_fields()
		
	if (quest.reqItem2): #if this quest has a second required component
		component1Display._render_stacked_item(staticData.allItemData[str(quest.reqItem2)], quest.reqItem2Quantity)
		if (global.playerQuestItems[quest.reqItem2].count >= quest.reqItem2Quantity): #and we have it in the quest items dictionary
			component2Display._set_green()
		else:
			component2Display._set_red()
	else:
		component2Display._clear_fields()
		
	if (quest.reqItem3): #if this quest has a third required component
		component1Display._render_stacked_item(staticData.allItemData[str(quest.reqItem3)], quest.reqItem3Quantity)
		if (global.playerQuestItems[quest.reqItem3].count >= quest.reqItem3Quantity): #and we have it in the quest items dictionary
			component3Display._set_green()
		else:
			component3Display._set_red()
	else:
		component3Display._clear_fields()
		
	if (quest.reqItem4): #if this quest has a fourth required component
		component1Display._render_stacked_item(staticData.allItemData[str(quest.reqItem4)], quest.reqItem4Quantity)
		if (global.playerQuestItems[quest.reqItem4].count >= quest.reqItem4Quantity): #and we have it in the quest items dictionary
			component4Display._set_green()
		else:
			component4Display._set_red()
	else:
		component4Display._clear_fields()



func _on_button_completeQuest_pressed():
	#give the player the promised item
	util.give_item_guild(quest.prizeItem1)
	#take the components
	if (quest.reqItem1):
		global.playerQuestItems[quest.reqItem1].count -= quest.reqItem1Quantity
	
	if (quest.reqItem2):
		global.playerQuestItems[quest.reqItem2].count -= quest.reqItem2Quantity
	
	if (quest.reqItem3):
		global.playerQuestItems[quest.reqItem3].count -= quest.reqItem3Quantity
	
	if (quest.reqItem4):
		global.playerQuestItems[quest.reqItem4].count -= quest.reqItem4Quantity
			
	#update display - cancel quest? remove from active? 
	_update_components_display()
	
func _on_button_back_pressed():
	get_tree().change_scene("res://main.tscn")