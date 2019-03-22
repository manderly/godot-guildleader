extends KinematicBody2D
# mob.gd

var mobName = "Default name"
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

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
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