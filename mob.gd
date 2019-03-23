extends KinematicBody2D
# mob.gd

var mobName = "Default name"
var mobID = 123
var entityType = "mob"
var level = -1
var hp = -1
var hpCurrent = -1
var mana = -1
var manaCurrent = -1
var baseResist = -1
var dps = -1
var strength = -1
var defense = -1
var dead = false
var sprite = "res://sprites/mobs/bat/bat_01.png"
var lootTable = "batLoot01"
#to access: mobInstance.equipment.mainHand
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
var walkable = false
var showName = true
	
func _ready():
	_hide_extended_stats()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	if (showName):
		$field_name.text = mobName
	else:
		$field_name.text = ""
	
	vignette_hide_stats()
	
func set_display_params(walkBool, nameBool):
	walkable = walkBool
	showName = nameBool
				
func _hide_extended_stats():
	$field_levelAndClass.hide()
	$field_debug.hide()
	
func vignette_hide_stats():
	$field_HP.hide()
	$label_hp.hide()
	$field_Mana.hide()
	$label_mana.hide()
	
func set_instance_data(data):
	print("data")
	print(data)
	mobName = data.mobName
	sprite = data.sprite
	level = data.level
	dead = data.dead
	mobID = 123 #todo: mob ID system
	hp = data.hp
	hpCurrent = data.hpCurrent
	mana = data.mana
	manaCurrent = data.manaCurrent
	baseResist = data.baseResist
	dps = data.dps
	strength = data.strength
	defense = data.strength
	lootTable = data.lootTable
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
	#weapon1Sprite = data.weapon1Sprite
	#weapon2Sprite = data.weapon2Sprite
	#shieldSprite = data.shieldSprite
	
func _draw_sprites():
	# a mob can be "one body" (like a bat or a goblin)
	# or it might be a humanoid and look a lot like heroes with all the same parts
	
	var none = "res://sprites/mobs/none.png"
	print(sprite)
	$body/oneSprite.texture = load("res://sprites/" + sprite)
	
	# todo: heroes all had heads, but mobs don't necessarily have a head
	# not sure how to handle heads yet
	
	#if (equipment.head):
	#	$body/head.texture = load("res://sprites/heroes/head/" + headSprite)
	#else:
	#	$body/head.texture = load(none)

	# mobs can walk around empty-handed, so check that gear actually exists 
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
		$body/chest.hide()
		#$body/chest.texture = load("res://sprites/heroes/chest/missing.png")
	
	if (equipment.legs):
		$body/legs.texture = load("res://sprites/heroes/legs/" + equipment.legs.bodySprite)
	else:
		$body/legs.hide()
	
	if (equipment.feet):
		$body/boot1.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
		$body/boot2.texture = load("res://sprites/heroes/feet/" + equipment.feet.bodySprite)
	else:
		$body/boot1.hide()
		$body/boot2.hide()

	
func get_base_resist(heroLevel):
	# mob's save roll is based on level difference between hero and mob
	#if mob > hero, mob has a greater chance to resist
	#if mob < hero, mob has a lesser chance to resist
					
	var adjustedResist = baseResist
					
	if (heroLevel > level):
		adjustedResist -= (heroLevel - level)
		if adjustedResist < 1:
			adjustedResist = 1
	elif (heroLevel < level):
		adjustedResist += (level - heroLevel)
		if adjustedResist > 19:
			adjustedResist = 19
	
	return adjustedResist

func get_melee_attack_damage():
	return dps * strength * level
	
func take_melee_damage(unmodifiedDamage):
	hpCurrent -= unmodifiedDamage
	
func take_spell_damage(dmg):
	# resists are handled in encounter generator so message can be appended to log 
	hpCurrent -= dmg
	
func say_hello():
	print(mobName + " says hello, I'm level " + str(level) + ". I have " + str(hpCurrent) + "/" + str(hp) + "hp")