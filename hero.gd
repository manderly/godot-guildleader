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

# These properties are specific to a hero
var heroID = -1 
var heroFirstName = "Firstname"
var heroLastName = ""
var recruited = false
var gender = "female"
var perks = {}
var perkPoints = 0
var xp = -1

# These properties relate to where a hero is on the main screen
var currentRoom = 0 #outside by default
var atHome = true
var staffedTo = ""
var staffedToID = ""
var savedPositionX = -1
var savedPositionY = -1

#Hero walking vars 
var walkDestX = -1
var walkDestY = -1
var startingX = 1
var startingY = 1
var target = Vector2()
var velocity = Vector2()
var speed = 20
var walking = false

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
			$field_name.text = heroFirstName
		else:
			$field_name.text = heroFirstName + " " + heroLastName
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
	if (currentRoom == 1): #large interior room
		walkDestX = rand_range(mainRoomMinX, mainRoomMaxX)
		walkDestY = rand_range(mainRoomMinY, mainRoomMaxY)
	else: #currentRoom == 0 #outside
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
	
func face_right():
	$body.set_scale(Vector2(-1,1))
	#$body/weapon1.offset.x = 20
	#$body/weapon2.offset.x = -20
	#$body/shield.offset.x = -28
	#$body/shield.set_scale(Vector2(abs($body.scale.x),1)) #todo: shield shouldn't flip
			
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
		
func save_current_position():
	#this works on the hero SCENE, but we have to pass it to the hero DATA
	for i in global.guildRoster.size():
		#pair hero scene to hero in data array
		#todo I bet this doesn't work if two heroes share a first name
		if (global.guildRoster[i].heroFirstName == heroFirstName):
			global.guildRoster[i].savedPositionX = get_position().x
			global.guildRoster[i].savedPositionY = get_position().y
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
			
	print("Saving this hero! " + heroFirstName + " level " + str(level) + " " + charClass)
	var saved_hero_data = {
		"filename":"heroFile",#get_filename(), #res://hero.tscn
		"parent":"/root",#get_parent().get_path(),
		"heroID":heroID,
		"heroFirstName":heroFirstName,
		"heroLastName":heroLastName,
		"charClass":charClass,
		"level":level,
		"xp":xp,
		"walkable":walkable,
		"currentRoom":currentRoom,
		"atHome":atHome,
		"staffedTo":thisHero.staffedTo,
		"staffedToID":thisHero.staffedToID,
		"recruited":thisHero.recruited,
		"gender":thisHero.gender,
		"dead":dead,
		"savedPositionX":get_position().x,#savedPosition.x,
		"savedPositionY":get_position().y,#savedPosition.y,
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
		"headSprite":thisHero.headSprite, #armor sprites should be derived from equipment 
		"isPlayer":thisHero.isPlayer,
		"entityType":thisHero.entityType
	}
	return saved_hero_data

func _physics_process(delta):
	if (walking):
		velocity = (target - position).normalized() * speed
		if (target - position).length() > 10:
			#move_and_slide(velocity) #last good but doesn't stop walking
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				#print(collision_info.collider.heroName)
				_stop_walking()
		else:
			_stop_walking()
			
    #var collision_info = move_and_collide(direction.normalized() * speed * delta)
    #if collision_info:
      #  collision_info.collider.queue_free()

func _stop_walking():
	target = get_position()
	velocity = 0
	$animationPlayer.play("idle")
	walking = false
	$idleTimer.start()
	
func set_instance_data(data):
	heroFirstName = data.heroFirstName
	heroLastName = data.heroLastName
	level = data.level
	xp = data.xp
	charClass = data.charClass
	currentRoom = data.currentRoom
	recruited = data.recruited
	dead = data.dead
	heroID = data.heroID
	atHome = data.atHome
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
	isPlayer = data.isPlayer

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
	strength = baseStrength + modifiedStrength
	defense = baseDefense + modifiedDefense
	intelligence = baseIntelligence + modifiedIntelligence
	regenRateHP = baseRegenRateHP + modifiedRegenRateHP
	regenRateMana = baseRegenRateMana + modifiedRegenRateMana
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
	
func change_class(classStr):
	if (classStr == "Cleric"):
		charClass = "Cleric"
		give_gear_loadout("clericNew")
	elif (classStr == "Druid"):
		charClass = "Druid"
		give_gear_loadout("druidNew")
	elif (classStr == "Rogue"):
		charClass = "Rogue"
		give_gear_loadout("rogueNew")
	elif (classStr == "Ranger"):
		charClass = "Ranger"
		give_gear_loadout("rangerNew")
	elif (classStr == "Warrior"):
		charClass = "Warrior"
		give_gear_loadout("warriorNew")
	elif (classStr == "Wizard"):
		charClass = "Wizard"
		give_gear_loadout("wizardNew")
	else:
		print("hero.gd: Attempting to change to invalid class")
		
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

func send_home():
	atHome = true
	staffedTo = ""
	staffedToID = -1
	
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
	print(heroFirstName + " says hello")
	
func set_dead():
	dead = true
	hpCurrent = 0
	manaCurrent = 0
	
func ghost_mode(ghostMode):
	if (ghostMode):
		print("ghost mode on")
		$body.modulate = Color(0.8, 0.7, 1)
		$particles_ghost.set_emitting(true)
		$particles_ghost.show()
	else:
		$body.modulate = Color(1, 1, 1)
		$particles_ghost.set_emitting(false)
		$particles_ghost.hide()
	
func get_nuke_dmg():
	return level * intelligence
	
func get_cleric_party_heal_amount():
	return 50 #todo: fancy formula
	
func get_druid_target_heal_amount():
	return 100 #todo: fancy formula 

func regen_hp_between_battles(campRespawnRate):
	var hpRegenerated = regenRateHP * (campRespawnRate / global.tickRate)
	hpCurrent += hpRegenerated
	if (hpCurrent > hp):
		hpCurrent = hp
	
func regen_mana_between_battles(campRespawnRate):
	var manaRegenerated = regenRateMana * (campRespawnRate / global.tickRate)
	manaCurrent += manaRegenerated
	if (manaCurrent > mana):
		manaCurrent = mana
	