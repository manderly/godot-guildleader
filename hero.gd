extends KinematicBody2D

#Hero properties - not governed by external spreadsheet data
#These are set when a hero is randomly generated in heroGenerator.gd 
var heroID = -1 
var heroName = "Default Name"
var heroClass = "NONE"
var level = -1
var xp = -1
var currentRoom = 0 #outside by default
var atHome = true
var staffedTo = ""
var recruited = false
var gender = "female"

#for distinguishing "walkers" (main scene) from usages of the hero not walking (hero page, buttons, etc) 
var justForDisplay = false

#Hero base stats come from external spreadsheet data
#These are first set when a hero is randomly generated in heroGenerator.gd

#BASE STATS - bulldoze these -1's with data that comes in from heroData.json data (heroGenerator.gd) 
var baseHp = -1
var baseMana = -1
var baseArmor = -1
var baseDps = -1
var baseStamina = -1
var baseDefense = -1
var baseIntelligence = -1
var baseSkillAlchemy = -1
var baseSkillBlacksmithing = -1
var baseSkillFletching = -1
var baseSkillJewelcraft = -1
var baseSkillTailoring = -1
var baseDrama = 0
var baseMood = 0
var basePrestige = -1
var baseGroupBonus = "none"
var baseRaidBonus = "none" 

#EQUIPMENT MODIFIED STATS - the total from the hero's worn items (equipment dictionary further down)
var modifiedHp = 0
var modifiedMana = 0
var modifiedArmor = 0
var modifiedDps = 0
var modifiedStamina = 0
var modifiedDefense = 0
var modifiedIntelligence = 0
var modifiedSkillAlchemy = 0
var modifiedSkillBlacksmithing = 0
var modifiedSkillFletching = 0
var modifiedSkillJewelcraft = 0
var modifiedSkillTailoring = 0
var modifiedPrestige = 0

#TODO: Buffs - someday, buffs will affect stats, too. 

#FINAL STATS - combine base and modified stats. For now, default to -1 until the math is done.  
var hp = -1
var mana = -1
var armor = -1
var dps = -1
var stamina = -1
var defense = -1
var intelligence = -1
var skillAlchemy = -1
var skillBlacksmithing = -1
var skillFletching = -1
var skillJewelcraft = -1
var skillTailoring = -1
var drama = 0
var mood = 0
var prestige = -1
var groupBonus = "none"
var raidBonus = "none"


#This hero's items (equipment)
#to access: heroInstance.equipment.mainHand
var equipment = {
	"mainHand": null,
	"offHand": null,
	"jewelry": null,
	"unknown": null,
	"head": null,
	"chest": null,
	"legs": null,
	"feet": null
} 

#Hero walking vars 
var walkDestX = -1
var walkDestY = -1
var startingX = 1
var target = Vector2()
var velocity = Vector2()
var speed = 20
var walking = false

#Hero sprite names (todo: should eventually take sprite data from equipment dictionary)
var headSprite = "head01.png"
var chestSprite = "body01.png"
var weapon1Sprite = "weapon01.png"
var weapon2Sprite = "none.png"
var shieldSprite = "none.png"
var legsSprite = "pants04.png"
var bootSprite = "boots04.png"

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

var outsideMinX = 150
var outsideMaxX = 380
var outsideMinY = 650
var outsideMaxY = 820


func _ready():
	$field_name.text = ""
	_hide_extended_stats()
	if (!justForDisplay):
		$field_name.text = heroName
		if (atHome && staffedTo == ""):
			_start_idle_timer()
		
func _just_for_display(walkBool):
	justForDisplay = walkBool
	
func _start_idle_timer():
	#idle for this random period of time and then start walking
	if (!justForDisplay):
		$idleTimer.set_wait_time(rand_range(5, 15))
		$idleTimer.start() #walk when the timer expires
	
func _start_walking():
	walking = true
	$animationPlayer.play("walk")
	#print(heroName + " is picking a random destination")
	#pick a random destination to walk to (in the main room for now)
	if (currentRoom == 1): #large interior room
		walkDestX = rand_range(mainRoomMinX, mainRoomMaxX)
		walkDestY = rand_range(mainRoomMinY, mainRoomMaxY)
	else: #currentRoom == 0 #outside
		walkDestX = rand_range(outsideMinX, outsideMaxX)
		walkDestY = rand_range(outsideMinY, outsideMaxY)
	startingX = get_position().x
	target = Vector2(walkDestX, walkDestY)
	#flip (or don't flip) the character's body
	if (startingX < target.x):
		#print(heroName + " walking RIGHT // started: " + str(startingX) + " // going to:" + str(target.x))
		#if already facing right (-1), don't do anything
		#if facing left (1), change to -1
		if ($body.scale.x == 1):
			$body.set_scale(Vector2(-1,1))
			$body/weapon1.offset.x = 20
			$body/weapon2.offset.x = -20
			$body/shield.offset.x = -28
			$body/shield.set_scale(Vector2(abs($body.scale.x),1)) #todo: shield shouldn't flip
	elif (startingX > target.x):
		#print(heroName + " walking LEFT // started: " + str(startingX) + " // going to:" + str(target.x))
		#if already facing left (1), don't do anything
		#if facing right (-1), change to 1 by multiplying -1 
		if ($body.scale.x == -1):
			$body.set_scale(Vector2(abs($body.scale.x),1))
			$body/weapon1.offset.x = 0
			$body/weapon2.offset.x = 0
			$body/shield.offset.x = 0
		
	#_physics_process(delta) handles the rest and determines when the heroes has arrived 
	
func _on_Timer_timeout():
	#idleTimer is up, time to start walking!
	_hide_extended_stats()
	_start_walking()
#
func _input_event(viewport, event, shape_idx):
	pass
	#print("old input event triggered")
    #if event is InputEventMouseButton \
    #and event.button_index == BUTTON_LEFT \
    #and event.is_pressed():
        #self.on_click()
		
	#if event is InputEventMouseButton \
    #and event.button_index == BUTTON_LEFT \
    #and event.is_released():
        #self.on_heroTouchRelease()

func _physics_process(delta):
	if (walking):
		velocity = (target - position).normalized() * speed
		if (target - position).length() > 10:
			move_and_slide(velocity)
		else:
			#print(heroName + " has arrived at their random destination")
			$animationPlayer.play("idle")
			walking = false
			$idleTimer.start()
		
func on_click():
	pass

func set_instance_data(data):
	heroName = data.heroName
	level = data.level
	xp = data.xp
	heroClass = data.heroClass
	currentRoom = data.currentRoom
	recruited = data.recruited
	heroID = data.heroID
	atHome = data.atHome
	staffedTo = data.staffedTo
	headSprite = data.headSprite #sprites are set in heroGenerator.gd
	#chestSprite = data.equipment.chest.bodySprite
	#legsSprite = data.equipment.legs.bodySprite
	#bootSprite = data.equipment.feet.bodySprite
	equipment = {
		"mainHand": data.equipment.mainHand,
		"offHand": data.equipment.offHand,
		"jewelry": data.equipment.jewelry,
		"unknown": null,
		"head": data.equipment.head,
		"chest": data.equipment.chest,
		"legs": data.equipment.legs,
		"feet": data.equipment.feet
	}
	weapon1Sprite = data.weapon1Sprite
	weapon2Sprite = data.weapon2Sprite
	shieldSprite = data.shieldSprite
	
func _draw_sprites():
	var none = "res://sprites/heroes/none.png"
	#everyone has a head, no need to else/if this one 
	$body/head.texture = load("res://sprites/heroes/head/" + headSprite)

	#heroes can walk around empty-handed, so check that gear actually exists 
	if (equipment.mainHand):
		$body/weapon1.texture = load("res://sprites/heroes/weaponMain/" + equipment.mainHand.bodySprite)
	else:
		$body/weapon1.texture = load(none)
	
	#shields are offhand items but they use a different node on the hero body 
	if (equipment.offHand):
		if (equipment.offHand.itemType == "shield"):
			$body/shield.texture = load("res://sprites/heroes/offHand/" + equipment.offHand.bodySprite)
			$body/weapon2.texture = load(none)
		else:
			$body/weapon2.texture = load("res://sprites/heroes/offHand/" + equipment.offHand.bodySprite)
			$body/shield.texture = load(none)
	else:
		$body/weapon2.texture = load(none)
		$body/shield.texture = load(none)

	#todo: figure out an elegant way to handle naked characters 
	if (equipment.chest):
		$body/chest.texture = load("res://sprites/heroes/chest/" + equipment.chest.bodySprite)
	else:
		$body/chest.texture = load("res://sprites/heroes/chest/missing.png")
	
	if (equipment.legs):
		$body/legs.texture = load("res://sprites/heroes/legs/" + equipment.legs.bodySprite)
	else:
		$body/legs.texture = load("res://sprites/heroes/legs/missing.png")
	
	if (equipment.feet):
		$body/boot1.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
		$body/boot2.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
	else:
		$body/boot1.texture = load("res://sprites/heroes/feet/missing.png")
		$body/boot2.texture = load("res://sprites/heroes/feet/missing.png")

#call this method after assigning equipment to a hero (or removing it from a hero)
func update_hero_stats():
	#global.logger(self, "updating hero stats to match equipment for: " + heroName)
	#add up the stats from the equipment any time equipment is added or removed from hero 
	#equipment is an object, so to iterate through it I made this array of names 
	var equipmentSlotNames = ["mainHand", "offHand", "jewelry", "unknown", "head", "chest", "legs", "feet"]
	
	#reset all the stats modified by armor to 0
	modifiedHp = 0
	modifiedMana = 0
	modifiedArmor = 0
	modifiedDps = 0
	modifiedStamina = 0
	modifiedDefense = 0
	modifiedIntelligence = 0
	modifiedSkillAlchemy = 0
	modifiedSkillBlacksmithing = 0
	modifiedSkillFletching = 0
	modifiedSkillJewelcraft = 0
	modifiedSkillTailoring = 0
	modifiedPrestige = 0
	
	#add up all the stats from armor 
	var equip = null
	for i in range(equipmentSlotNames.size()):
		equip = equipment[equipmentSlotNames[i]]
		#equip should now be the actual item in that slot 
		if (equip):
			modifiedHp += equip.hpRaw
			modifiedMana += equip.manaRaw
			modifiedArmor += equip.armor
			modifiedDps += equip.dps
			modifiedStamina += equip.stamina
			modifiedDefense += equip.defense
			modifiedIntelligence += equip.intelligence
			modifiedPrestige += equip.prestige
			#skill stats to come later (todo) 
			#groupBonus is a different system (todo) 
			#raidBonus is a different system (todo)
			#drama and mood are not affected by equipment
	
	#finally, update the hero's stats 
	#global.logger(self, "updating hero stats on hero itself")
	hp = baseHp + modifiedHp
	mana = baseMana + modifiedMana
	#global.logger(self, "new hp total: " + str(hp))
	armor = baseArmor + modifiedArmor
	dps = baseDps + modifiedDps
	stamina = baseStamina + modifiedStamina
	defense = baseDefense + modifiedDefense
	intelligence = baseIntelligence + modifiedIntelligence
	skillAlchemy = baseSkillAlchemy + modifiedSkillAlchemy
	skillBlacksmithing = baseSkillBlacksmithing + modifiedSkillBlacksmithing
	skillFletching = baseSkillFletching + modifiedSkillFletching
	skillJewelcraft = baseSkillJewelcraft + modifiedSkillJewelcraft
	skillTailoring = baseSkillTailoring + modifiedSkillTailoring
	prestige = basePrestige + modifiedPrestige
	drama = "Low"
	mood = "Happy"

func give_item(itemNameStr):
	#This method replaced this code in main.gd:
	#newHero.equipment["chest"] = global.allGameItems["Novice's Robe"]
	#To use: hero.give_item("Item Name Here") where item is a known item in global.allGameItems
	
	#gets the item out of allGameItems by name, and puts it in the hero's correct equip. slot
	equipment[global.allGameItems[itemNameStr].slot] = global.allGameItems[itemNameStr]

#if we release before 300ms is up, it's a short press - just show the hero name and stop their walking
#if we release after 300ms is up, it's a long press - open the hero page 
func _open_hero_page():
	if (self.recruited):
		for i in range(global.guildRoster.size()):
			if (global.guildRoster[i].heroID == heroID):
				global.selectedHero = global.guildRoster[i]
				global.currentMenu = "heroPage"
				get_tree().change_scene("res://menus/heroPage.tscn")
				break
	else:
		for i in range(global.unrecruited.size()):
			if (global.unrecruited[i].heroID == heroID):
				global.selectedHero = global.unrecruited[i]
				get_tree().change_scene("res://menus/heroPage.tscn")
				break
				
func _hide_extended_stats():
	$field_levelAndClass.text = ""
	$field_xp.text = ""
	$field_debug.text = ""
	
func _show_extended_stats():
	$field_levelAndClass.text = "Level " + str(level) + " " + heroClass
	$field_xp.text = str(xp) + " xp"
	$field_debug.text = "(room: " + str(currentRoom) + " id: " + str(heroID) + ")"
	
func _on_heroButton_pressed():
	if (walking):
		walking = false
	$touchTimer.set_wait_time(0.5)
	$touchTimer.start()

func _on_heroButton_released():
	if $touchTimer.is_stopped():
		#long press detected
		_open_hero_page()
	else:
		#short press detected
		_show_extended_stats()
		$idleTimer.set_wait_time(5)
		$idleTimer.start()
		
func _on_touchTimer_timeout():
	#touch timer timed out 
	$touchTimer.stop()
