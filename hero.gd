extends "baseEntity.gd"
#hero.gd

#todo: globalize these
var mainRoomMinX = 110
var mainRoomMaxX = 360
var mainRoomMinY = 250
var mainRoomMaxY = 410

var outsideMinX = 150
var outsideMaxX = 380
var outsideMinY = 650
var outsideMaxY = 820

var bedroomMinX = 200
var bedroomMaxX = 340
var bedroomMinY = 50
var bedroomMaxY = 85

# These properties are specific to a hero
var heroID = -1 
var heroFirstName = "Firstname"
var heroLastName = ""
var recruited = false
var gender = "female"
var perks = {}
var perkPoints = 0
var xp = -1

var inventory = null

# These properties relate to where a hero is on the main screen
var currentRoom = 0 #outside by default
var atHome = true
var idleIn = "outside" #outside, graveyard, main, bedroom, tradeskill
var staffedTo = ""
var staffedToID = ""
var savedPositionX = -1
var savedPositionY = -1
var facing = "left"
var savedFacing = "left"

#Hero walking vars 
var walkDestX = -1
var walkDestY = -1
var startingX = 1
var startingY = 1
var target = Vector2()
var velocity = Vector2()
var speed = 20
var walking = false
var walkingToBattlePoint = false

var headIndex = 0

var longEnoughClickToOpenHeroPage = false
var isPlayer = false # to distiguish heroes the game generated vs. a hero the player made

#three possible ways to display a hero sprite:
#walking with name
#icon with name
#icon with no name

func _ready():
	entityType = "hero"

	_hide_extended_stats()
	if (walkable):
		if (atHome && staffedTo == ""):
			_start_idle_timer()
	
	if (showName):
		if (level < global.surnameLevel):
			$field_name.text = get_first_name()
		else:
			$field_name.text = get_first_name() + " " + get_last_name()
	else:
		$field_name.text = ""
	
	vignette_hide_stats()
		
func set_display_params(walkBool, nameBool):
	walkable = walkBool
	showName = nameBool
	
func _start_idle_timer():
	#idle for this random period of time and then start walking
	if (walkable):
		$idleTimer.set_wait_time(rand_range(3, 15))
		$idleTimer.start() #walk when the timer expires
	
func _start_walking():
	walking = true
	$animationPlayer.play("walk")
	#pick a random destination to walk to (in the main room for now)
	if (idleIn == "main"): #large interior "main" room
		walkDestX = rand_range(mainRoomMinX, mainRoomMaxX)
		walkDestY = rand_range(mainRoomMinY, mainRoomMaxY)
	elif (idleIn == "outside"): #currentRoom == 0 #outside
		walkDestX = rand_range(outsideMinX, outsideMaxX)
		walkDestY = rand_range(outsideMinY, outsideMaxY)
	elif (idleIn == "graveyard"):
		# todo: graveyard coords
		walkDestX = rand_range(outsideMinX, outsideMaxX)
		walkDestY = rand_range(outsideMinY, outsideMaxY)
	elif (idleIn == "bedroom"):
		# the X/Y min/max are relative to the scene the hero is in 
		walkDestX = rand_range(bedroomMinX, bedroomMaxX)
		walkDestY = rand_range(bedroomMinY, bedroomMaxY)
	else:
		# use outside coords as a catch-all 
		walkDestX = rand_range(outsideMinX, outsideMaxX)
		walkDestY = rand_range(outsideMinY, outsideMaxY)
	
	startingX = get_position().x
	startingY = get_position().y
	
	if (abs(startingX - walkDestX) < 5):
		#print(abs(startingX - walkDestX))
		#print("starting x and destination x are very close")
		walkDestX += 5
		
	if (abs(startingY - walkDestY) < 5):
		#print(abs(startingX - walkDestX))
		#print("starting x and destination x are very close")
		walkDestY += 5
	
	target = Vector2(walkDestX, walkDestY)
	#flip (or don't flip) the character's body
	if (startingX < target.x):
		# if facing left, don't change anything
		if ($body.scale.x == 1):
			face_right()
	elif (startingX > target.x):
		#if already facing right, don't change anything
		if ($body.scale.x == -1):
			face_left()
		
	#_physics_process(delta) handles the rest and determines when the heroes has arrived 
	
func face_left():
	facing = "left"
	$body.set_scale(Vector2(abs($body.scale.x),1))
	$body/weapon1.offset.x = 0
	$body/weapon2.offset.x = 0
	$body/shield.offset.x = 0
			
func face_right():
	facing = "right"
	$body.set_scale(Vector2(-1,1))
	$body/weapon1.offset.x = 20
	$body/weapon2.offset.x = -20
	$body/shield.offset.x = -28
	#$body/weapon1.set_rotation_degrees(140) #set_rotation_degrees(N), rotation_degrees = N, set_rot(N), set_rotd(N), 
	$body/shield.set_scale(Vector2(abs($body.scale.x),1)) #todo: shield shouldn't flip
			
func _on_Timer_timeout():
	#idleTimer is up, time to start walking!
	_hide_extended_stats()
	_start_walking()

func vignette_update_hp_and_mana(oldHP, newHP, totalHP, oldMana, newMana, totalMana):
	#if the regen tick took us above the total allowed, reset to total 
	if (newHP > totalHP):
		hpCurrent = totalHP
	else:
		hpCurrent = newHP

	if (newMana > totalMana):
		manaCurrent = totalMana
	else:
		manaCurrent = newMana
		
	$field_HP.text = str(oldHP) + "/" + str(totalHP)
	$field_Mana.text = str(oldMana) + "/" + str(totalMana)
	#todo: animate the change
	yield(get_tree().create_timer(1.0), "timeout")

	$field_HP.text = str(hpCurrent) + "/" + str(totalHP)
	$field_Mana.text = str(manaCurrent) + "/" + str(totalMana)
		
func vignette_walk_to_point(vignetteX, vignetteY):
	walkDestX = vignetteX
	walkDestY = vignetteY
	$animationPlayer.play("walk")
	startingX = get_position().x
	startingY = get_position().y
	#print("walking from " + str(startingX) + " to " + str(walkDestX))
	target = Vector2(walkDestX, walkDestY)
	walkingToBattlePoint = true
	#physics_process handles it from here 
	
func save_current_position():
	#this works on the hero SCENE, but we have to pass it to the hero DATA
	for i in global.guildRoster.size():
		#pair hero scene to hero in data array
		#todo I bet this doesn't work if two heroes share a first name
		if (global.guildRoster[i].get_first_name() == heroFirstName):
			#print("saving " + global.guildRoster[i].get_first_name() + " position and facing: " + facing) 
			global.guildRoster[i].savedPositionX = get_position().x
			global.guildRoster[i].savedPositionY = get_position().y
			global.guildRoster[i].savedFacing = facing
	#todo: is there some smarter way to do this? I wanted to just set
	#the variables on this hero instance but it has to be done in the roster array 
	
func save():
	var thisHero = self
	if (thisHero.recruited):
		for hero in global.guildRoster:
			if (heroID == hero.heroID):
				thisHero = hero
	elif (!thisHero.recruited):
		for hero in global.unrecruited:
			if (heroID == hero.heroID):
				thisHero = hero
			
	#print('rosterHero ID: ' + String(thisHero.heroID))
			
	print("Saving this hero! " + get_first_name() + " level " + str(level) + " " + charClass)
	var saved_hero_data = {
		"filename":"heroFile",#get_filename(), #res://hero.tscn
		"parent":"/root",#get_parent().get_path(),
		"heroID":heroID,
		"heroFirstName":get_first_name(),
		"heroLastName":get_last_name(),
		"charClass":charClass,
		"level":level,
		"xp":xp,
		"walkable":walkable,
		"currentRoom":currentRoom,
		"atHome":atHome,
		"idleIn":idleIn,
		"staffedTo":thisHero.staffedTo,
		"staffedToID":thisHero.staffedToID,
		"recruited":thisHero.recruited,
		"gender":thisHero.gender,
		"dead":dead,
		"savedPositionX":get_position().x,#savedPosition.x,
		"savedPositionY":get_position().y,#savedPosition.y,
		"savedFacing":thisHero.facing,
		"hpCurrent":thisHero.hpCurrent,
		"hp":thisHero.hp,
		"manaCurrent":thisHero.manaCurrent,
		"mana":thisHero.mana,
		"armor":thisHero.armor,
		"dps":thisHero.dps,
		"strength":thisHero.strength,
		"defense":thisHero.defense,
		"intelligence":thisHero.intelligence,
		"regenRateHP":thisHero.regenRateHP,
		"regenRateMana":thisHero.regenRateMana,
		"criticalHitChance":thisHero.criticalHitChance,
		"skillAlchemy":thisHero.skillAlchemy,
		"skillBlacksmithing":thisHero.skillBlacksmithing,
		"skillChronomancy":thisHero.skillChronomancy,
		"skillFletching":thisHero.skillFletching,
		"skillJewelcraft":thisHero.skillJewelcraft,
		"skillTailoring":thisHero.skillTailoring,
		"skillHarvesting":thisHero.skillHarvesting,
		"drama":thisHero.drama,
		"mood":thisHero.mood,
		"prestige":thisHero.prestige,
		"groupBonus":thisHero.groupBonus,
		"raidBonus":thisHero.raidBonus,
		"equipment":thisHero.equipment,
		"inventory":thisHero.inventory,
		"perkPoints":thisHero.perkPoints,
		"perks":thisHero.perks,
		"headSprite":thisHero.headSprite, #armor sprites should be derived from equipment 
		"isPlayer":thisHero.isPlayer,
		"entityType":thisHero.entityType,
		"showMyHelm":thisHero.showMyHelm
	}
	return saved_hero_data

func _physics_process(delta):
	if (walking):
		velocity = (target - position).normalized() * speed
		if (target - position).length() > 10:
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				#print(collision_info.collider.heroName)
				_stop_walking()
		else:
			_stop_walking()
	elif (walkingToBattlePoint):
		velocity = (target - position).normalized() * speed
		if ((target - position).length() > 1):
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				_stop_walking()
		else:
			_stop_walking()

func _stop_walking():
	target = get_position()
	velocity = 0
	$animationPlayer.play("idle")
	if (walking):
		walking = false
		$idleTimer.start()
	elif (walkingToBattlePoint):
		walkingToBattlePoint = false

func auto_assign_bedroom():
	# find an empty spot in the bedrooms object
	# assign this hero (by ID) to the first empty spot found
	# get all the keys from the object as an array
	var bedroomIDs = global.bedrooms.keys()
	#bedrooms = [bedroom0, bedroom1]
	
	# iterate through array, using each key to access the array of hero IDs within
	var foundAHome = false
	for i in range(bedroomIDs.size()):  # bedroom0, bedroom1, etc. 
		if (!foundAHome):
			var key = bedroomIDs[i]
			for j in range(global.bedrooms[key].occupants.size()):
				if (global.bedrooms[key].occupants[j] == 0):
					#print("setting " + bedroomIDs[i] + " index " + str(j) + " to: " + str(hero.heroID))
					global.bedrooms[key].occupants[j] = heroID
					foundAHome = true
					break # exit j loop
					
func has_perk(perkIDStr):
	var hasPerk = false
	if (perkIDStr in perks):
		if (perks[perkIDStr].pointsSpent >= 1):
			hasPerk = true
	return hasPerk
	
func get_perk_bonus(perkIDStr):
	var bonus = 0
	if (perkIDStr in perks):
		if (perks[perkIDStr].pointsSpent >= 1):
			bonus += perks[perkIDStr].level1
		
		if (perks[perkIDStr].pointsSpent >= 2):
			bonus += perks[perkIDStr].level2
			
		if (perks[perkIDStr].pointsSpent == 3):
			bonus += perks[perkIDStr].level3
		
	return bonus
		
func set_instance_data(data):
	heroFirstName = data.get_first_name()
	heroLastName = data.get_last_name()
	level = data.level
	xp = data.xp
	charClass = data.charClass
	currentRoom = data.currentRoom
	recruited = data.recruited
	dead = data.dead
	heroID = data.heroID
	atHome = data.atHome
	idleIn = data.idleIn
	staffedTo = data.staffedTo
	sprite = data.sprite #oneBody sprite, if present (not present if humanoid)
	headSprite = data.headSprite #sprites are set in heroGenerator.gd
	#chestSprite = data.equipment.chest.bodySprite
	#legsSprite = data.equipment.legs.bodySprite
	#bootSprite = data.equipment.feet.bodySprite
	hp = data.hp
	hpCurrent = data.hpCurrent
	mana = data.mana
	manaCurrent = data.manaCurrent
	regenRateHP = data.regenRateHP
	regenRateMana = data.regenRateMana
	criticalHitChance = data.criticalHitChance
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
	savedPositionX = data.savedPositionX
	savedPositionY = data.savedPositionY
	savedFacing = data.savedFacing
	isPlayer = data.isPlayer
	showMyHelm = data.showMyHelm
	perks = data.perks

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
	modifiedStrength = 0
	modifiedDefense = 0
	modifiedIntelligence = 0
	modifiedRegenRateHP = 0
	modifiedRegenRateMana = 0
	modifiedCriticalHitChance = 0
	modifiedSkillAlchemy = 0
	modifiedSkillBlacksmithing = 0
	modifiedSkillChronomancy = 0
	modifiedSkillFletching = 0
	modifiedSkillJewelcraft = 0
	modifiedSkillTailoring = 0
	modifiedSkillHarvesting = 0
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
			modifiedStrength += equip.strength
			modifiedDefense += equip.defense
			modifiedIntelligence += equip.intelligence
			modifiedRegenRateHP += equip.regenRateHP
			modifiedRegenRateMana += equip.regenRateMana
			#todo: equipment could/should offer extra bonuses, like a crit chance
			#modifiedCriticalHitChance += equip.criticalHitChance
			modifiedPrestige += equip.prestige
			#skill stats to come later (todo) 
			#groupBonus is a different system (todo) 
			#raidBonus is a different system (todo)
			#drama and mood are not affected by equipment

	# calculate perk bonuses
	var dpsFromPerks = get_perk_bonus("perkAny01")
	var hpFromPerks = get_perk_bonus("perkAny02")
	var hpFromPerksMelee = get_perk_bonus("perkMelee01")
	var manaFromPerksCaster = get_perk_bonus("perkCaster01")
	var manaRegenRateFromPerks = get_perk_bonus("perkCaster02")
	var criticalHitChanceFromPerks = get_perk_bonus("perkAny03")
	
	#finally, update the hero's stats 
	#global.logger(self, "updating hero stats on hero itself")
	hp = baseHp + modifiedHp + hpFromPerks
	hp += hp * (hpFromPerksMelee * .01)
	
	mana = baseMana + modifiedMana 
	mana += mana * (manaFromPerksCaster * .01)
	
	armor = baseArmor + modifiedArmor
	dps = baseDps + modifiedDps + dpsFromPerks
	strength = baseStrength + modifiedStrength
	defense = baseDefense + modifiedDefense
	intelligence = baseIntelligence + modifiedIntelligence
	
	regenRateHP = baseRegenRateHP + modifiedRegenRateHP
	
	# todo: finish checking that perks actually affect mana regen rate
	regenRateMana = baseRegenRateMana + modifiedRegenRateMana + manaRegenRateFromPerks
	#regenRateMana += (regenRateMana * (manaRegenRateFromPerks * .01)) # from when regen rate perk was a % instead of a flat +N 
	
	criticalHitChance = baseCriticalHitChance + modifiedCriticalHitChance
	criticalHitChance = criticalHitChance + criticalHitChanceFromPerks
	
	skillAlchemy = baseSkillAlchemy + modifiedSkillAlchemy
	skillBlacksmithing = baseSkillBlacksmithing + modifiedSkillBlacksmithing
	skillChronomancy = baseSkillChronomancy + modifiedSkillChronomancy
	skillFletching = baseSkillFletching + modifiedSkillFletching
	skillJewelcraft = baseSkillJewelcraft + modifiedSkillJewelcraft
	skillTailoring = baseSkillTailoring + modifiedSkillTailoring
	skillHarvesting = baseSkillHarvesting + modifiedSkillHarvesting
	prestige = basePrestige + modifiedPrestige
	drama = "Low"
	mood = "Happy"

func give_existing_item(item): #takes the actual item (use with vault)
	#hero.give_existing_item(actualItemObject)
	equipment[item.slot] = item
	
func set_hero_class(classStr):
	if (classStr == "Wizard"):
		charClass = "Wizard"
		archetype = "Caster"
		# base entity method 
		give_gear_loadout("wizardNew")  #"wizardNew")
		#if we need better wizards, here's a twinked one:
		#give_gear_loadout("wizardUber")
			
	elif (classStr == "Rogue"):
		charClass = "Rogue"
		archetype = "Melee"
		give_gear_loadout("rogueNew") #"rogueNew")

	elif (classStr == "Warrior"):
		charClass = "Warrior"
		archetype = "Melee"
		give_gear_loadout("warriorNew") #"warriorNew")
	
	elif (classStr == "Ranger"):
		charClass = "Ranger"
		archetype = "Melee"
		give_gear_loadout("rangerNew") #ranger12
		
	elif (classStr == "Cleric"):
		charClass = "Cleric"
		archetype = "Support"
		give_gear_loadout("clericNew") #cleric12

	elif (classStr == "Druid"):
		charClass = "Druid"
		archetype = "Support"
		give_gear_loadout("druidNew")
			
	else:
		print("ERROR - BAD HERO CLASS TYPE")
		
	#build perks object out of which perks this hero can actually use
	perks = {}
	for key in staticData.perks.keys():
		if (staticData.perks[key].restriction == "any" ||
			staticData.perks[key].restriction.to_lower() == archetype.to_lower() ||
			staticData.perks[key].restriction.to_lower() == charClass.to_lower()):
			#check if it's for anyone, this hero's archetype, or this hero's class
			#if so, give this hero this perk option 
			perks[key] = staticData.perks[key].duplicate()
	
func get_class():
	return charClass
	
func change_head(headStr): #pass in the string of the head sprite 
	headSprite = headStr
		
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
	$field_levelAndClass.hide()
	$field_xp.hide()
	$field_debug.hide()
	
func _show_extended_stats():
	$field_levelAndClass.text = "Level " + str(level) + " " + charClass
	$field_xp.text = str(xp) + "/" + str(staticData.levelXpData[str(level)].total) + " xp"
	$field_debug.text = "(room: " + str(currentRoom) + " id: " + str(heroID) + ")"
	$field_levelAndClass.show()
	$field_xp.show()
	#$field_debug.show()
	
func _on_heroButton_pressed():
	if (walkable):
		if (walking):
			walking = false
		$touchTimer.set_wait_time(1)
		$touchTimer.start()

func _on_heroButton_released():
	if (walkable):
		if $touchTimer.is_stopped():
			#long press detected (timer had managed to begin and stop before the user released)
			if (longEnoughClickToOpenHeroPage):
				_open_hero_page()
		else:
			#short press detected (timer is still going when user releases)
			_show_extended_stats()
			longEnoughClickToOpenHeroPage = false
			$idleTimer.set_wait_time(0.5)
			$idleTimer.start()
		
func _on_touchTimer_timeout():
	#touch timer timed out, we're now clear to open hero page on release 
	#provided the player releases over a hero and does not drag off that hero 
	$touchTimer.stop()
	longEnoughClickToOpenHeroPage = true

func _on_heroButton_tree_exited():
	#drag off hero without releasing = do not open hero page 
	$touchTimer.stop()
	longEnoughClickToOpenHeroPage = false
	
func set_first_name(name):
	heroFirstName = name

func set_last_name(name):
	heroLastName = name
	
func get_first_name():
	return heroFirstName
	
func get_last_name():
	return heroLastName

func send_home():
	atHome = true
	staffedTo = ""
	staffedToID = -1
	idleIn = "bedroom"
	
func give_xp(xpNum):
	xp += xpNum
	
func make_level(levelNum):
	if (levelNum > 1):
		for level in range(levelNum - 1):
			level_up()
	
func restore_hp_mana():
	hpCurrent = hp
	manaCurrent = mana
	
func level_up():
	xp = int(0)
	level += int(1)
	baseHp = int(round(baseHp * classLevelModifiers[charClass].hp))
	baseMana = int(round(baseMana * classLevelModifiers[charClass].mana))
	baseStrength = int(round(baseStrength * classLevelModifiers[charClass].strength))
	baseDefense = int(round(baseDefense * classLevelModifiers[charClass].defense))
	baseRegenRateHP = int(round(level/2))
	baseRegenRateMana = int(round(level/2))
	update_hero_stats()
	hpCurrent = hp #refill hp and mana when leveling up 
	manaCurrent = mana
	
func give_perk_points(quantity):
	perkPoints += quantity
	
func take_perk_points(quantity):
	perkPoints -= quantity

func vignette_recover_tick():
	#print(heroFirstName + " is recovering " + str(regenRateHP) + " hp and " + str(regenRateMana) + " mana")
	#print(heroFirstName + " is starting with " + str(hpCurrent) + " hp")
	vignette_update_hp_and_mana(hpCurrent, hpCurrent+regenRateHP, hp, manaCurrent, manaCurrent+regenRateMana, mana)
	
func say_hello():
	print(get_first_name() + " says hello")
	
func set_dead():
	dead = true
	hpCurrent = 0
	manaCurrent = 0
	
func ghost_mode(ghostMode):
	if (ghostMode):
		print("ghost mode on")
		$body.modulate = tints.ghost #Color(0.8, 0.7, 1)
		$particles_ghost.set_emitting(true)
		$particles_ghost.show()
	else:
		$body.modulate = Color(1, 1, 1)
		$particles_ghost.set_emitting(false)
		$particles_ghost.hide()

func get_critical_extra_dmg():
	var extraDamage = 0
	var roll = randi()%100+1 #(roll between 1-100)
	if (roll <= criticalHitChance):
		#how much extra damage? random again to find out 
		extraDamage = randi()%((level*5)+20)
		print("extra damage: " + str(extraDamage))
		# SUPER extra damage? random one last time to find out
		var impressiveDamageRoll = randi()%200
		print(impressiveDamageRoll)
		if (impressiveDamageRoll <= intelligence):
			extraDamage = (extraDamage*2) #double it 
			print("adding impressive damage for a nuke of: " + str(extraDamage))
	return extraDamage
	
func get_nuke_dmg():
	var nukeDmg = level * intelligence
	return nukeDmg
	
func get_cleric_individual_heal_amount():
	#todo: take perks into account
	var healAmount = 0;
	var healManaCost = level * 10
	if (manaCurrent > healManaCost):
		healAmount = (level * 5) + (intelligence * 2)
		manaCurrent -= healManaCost
	return healAmount 
	
func get_cleric_party_heal_amount():
	#todo: take perks into account
	var healAmount = 0;
	var healManaCost = level * 8
	if (manaCurrent > healManaCost):
		healAmount = (level * 3) + (intelligence * 2)
		manaCurrent -= healManaCost
	return healAmount 

func warrior_taunt_attacker():
	var taunt = false;
	# todo: take perk into account
	var tauntRand = _get_rand_between(0, 20)
	if (tauntRand >= 15):
		taunt = true
	return taunt
	
func get_ranger_heart_shot():
	var heartShot = false
	# if perk active, ranger has a 2% chance of doing an instakill 
	var roll = randi()%100+1 #(roll between 1-100)
	if (roll <= 2):
		heartShot = true
	return heartShot
	
func get_druid_target_heal_amount():
	return 100 #todo: fancy formula 

func regen_hp_between_battles(campRespawnRate):
	var startingHP = hpCurrent #snapshot so we can return the delta
	var hpRegenerated = regenRateHP * (campRespawnRate / global.tickRate)
	#print("recovering this many hp: " + str(hpRegenerated))
	hpCurrent += hpRegenerated
	if (hpCurrent > hp):
		hpCurrent = hp
		
	return (hpCurrent - startingHP) #so we can append it to encounter log
	
func regen_mana_between_battles(campRespawnRate):
	var startingMana = manaCurrent
	var manaRegenerated = regenRateMana * (campRespawnRate / global.tickRate)
	manaCurrent += manaRegenerated
	if (manaCurrent > mana):
		manaCurrent = mana
	
	return (manaCurrent - startingMana) #so we can append it to encounter log 
	