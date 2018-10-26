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