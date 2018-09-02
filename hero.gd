extends KinematicBody2D

#Hero properties - not governed by external spreadsheet data
#These are set when a hero is randomly generated in heroGenerator.gd 
var heroID = -1 
var heroName = "Default Name"
var heroClass = "NONE"
var level = -1
var xp = -1
var currentRoom = 0 #outside by default
var available = true
var recruited = false

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
var target = Vector2()
var velocity = Vector2()
var speed = 20
var walking = false

#Hero sprite names (todo: should eventually take sprite data from equipment dictionary)
var headSprite = "head01.png"
var bodySprite = "body01.png"
var weapon1Sprite = "weapon01.png"
var weapon2Sprite = "weapon02.png"

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
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$field_name.text = heroName
	$field_levelAndClass.text = "Level " + str(level) + " " + heroClass
	$field_xp.text = str(xp) + " xp"
	$field_debug.text = "(room: " + str(currentRoom) + " id: " + str(heroID) + ")"
	_start_idle_timer()


func _start_idle_timer():
	#idle for this random period of time and then start walking
	$idleTimer.set_wait_time(rand_range(5, 15))
	$idleTimer.start() #walk when the timer expires
	
func _start_walking():
	walking = true
	#print(heroName + " is picking a random destination")
	#pick a random destination to walk to (in the main room for now)
	if (currentRoom == 1): #large interior room
		walkDestX = rand_range(mainRoomMinX, mainRoomMaxX)
		walkDestY = rand_range(mainRoomMinY, mainRoomMaxY)
	else: #currentRoom == 0 #outside
		walkDestX = rand_range(outsideMinX, outsideMaxX)
		walkDestY = rand_range(outsideMinY, outsideMaxY)
	target = Vector2(walkDestX, walkDestY)
	#_physics_process(delta) handles the rest and determines when the heroes has arrived 
	
func _on_Timer_timeout():
	#print(heroName + " is done idling, time to walk!")
	_start_walking()

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        self.on_click()

func _physics_process(delta):
	if (walking):
		velocity = (target - position).normalized() * speed
		if (target - position).length() > 10:
			move_and_slide(velocity)
		else:
			#print(heroName + " has arrived at their random destination")
			walking = false
			$idleTimer.start()
		
func on_click():
	#loop through the heroes and find a unique ID to match to 
	#figure out what hero data we are viewing from the global hero array
	#print("hero.gd: Recruited status: " + str(self.recruited))
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

	
func set_instance_data(data):
	heroName = data.heroName
	level = data.level
	xp = data.xp
	heroClass = data.heroClass
	currentRoom = data.currentRoom
	recruited = data.recruited
	heroID = data.heroID
	headSprite = data.headSprite
	bodySprite = data.bodySprite
	weapon1Sprite = data.weapon1Sprite
	weapon2Sprite = data.weapon2Sprite
	
func _draw_sprites():
	$base/head.texture = load("res://sprites/heroes/" + headSprite)
	$base/body.texture = load("res://sprites/heroes/" + bodySprite)
	$base/weapon1.texture = load("res://sprites/heroes/" + weapon1Sprite)
	$base/weapon2.texture = load("res://sprites/heroes/" + weapon2Sprite)

#call this method after assigning equipment to a hero (or removing it from a hero)
func update_hero_stats():
	global.logger(self, "updating hero stats to match equipment for: " + heroName)
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
			#groupBonus is a different system (todo) 
			#raidBonus is a different system (todo)
			#drama and mood are not affected by equipment
	
	#finally, update the hero's stats 
	global.logger(self, "updating hero stats on hero itself")
	hp = baseHp + modifiedHp
	mana = baseMana + modifiedMana
	global.logger(self, "new hp total: " + str(hp))
	armor = baseArmor + modifiedArmor
	dps = baseDps + modifiedDps
	stamina = baseStamina + modifiedStamina
	defense = baseDefense + modifiedDefense
	intelligence = baseIntelligence + modifiedIntelligence
	prestige = basePrestige + modifiedPrestige
	drama = "Low"
	mood = "Happy"


