extends "basehero.gd"
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

#for distinguishing "walkers" (main scene) from usages of the hero not walking (hero page, buttons, etc) 
var walkable = false
var showName = true

var battlePrint = false

#three possible ways to display a hero sprite:
#walking with name
#icon with name
#icon with no name

func _ready():
	_hide_extended_stats()
	if (walkable):
		if (atHome && staffedTo == ""):
			_start_idle_timer()
	
	if (showName):
		$field_name.text = heroName
	else:
		$field_name.text = ""
		
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

func save_current_position():
	#this works on the hero SCENE, but we have to pass it to the hero DATA
	for i in global.guildRoster.size():
		#pair hero scene to hero in data array
		if (global.guildRoster[i].heroName == heroName):
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
			
	print('rosterHero ID: ' + String(thisHero.heroID))
			
	print("Saving this hero! " + heroName + " level " + str(level) + " " + heroClass)
	var saved_hero_data = {
		"filename":"heroFile",#get_filename(), #res://hero.tscn
		"parent":"/root",#get_parent().get_path(),
		"heroID":heroID,
		"heroName":heroName,
		"heroClass":heroClass,
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
		"skillAlchemy":thisHero.skillAlchemy,
		"skillBlacksmithing":thisHero.skillBlacksmithing,
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
		"headSprite":thisHero.headSprite #armor sprites should be derived from equipment 
	}
	print('heroName' + saved_hero_data.heroName)
	print('baseHp' + String(thisHero.baseHp))
	#print(saved_hero_data.skillBlacksmithing)
	return saved_hero_data
	
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
	heroName = data.heroName
	level = data.level
	xp = data.xp
	heroClass = data.heroClass
	currentRoom = data.currentRoom
	recruited = data.recruited
	dead = data.dead
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
	savedPositionX = data.savedPositionX
	savedPositionY = data.savedPositionY
	
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
	modifiedStrength = 0
	modifiedDefense = 0
	modifiedIntelligence = 0
	modifiedSkillAlchemy = 0
	modifiedSkillBlacksmithing = 0
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
	skillAlchemy = baseSkillAlchemy + modifiedSkillAlchemy
	skillBlacksmithing = baseSkillBlacksmithing + modifiedSkillBlacksmithing
	skillFletching = baseSkillFletching + modifiedSkillFletching
	skillJewelcraft = baseSkillJewelcraft + modifiedSkillJewelcraft
	skillTailoring = baseSkillTailoring + modifiedSkillTailoring
	skillHarvesting = baseSkillHarvesting + modifiedSkillHarvesting
	prestige = basePrestige + modifiedPrestige
	drama = "Low"
	mood = "Happy"

#this method generates a brand new instance of the item, it's an equivalent
#to the method used in util.gd to give new items to the guild
func give_new_item(itemNameStr): 
	#To use: hero.give_item("Item Name Here")
	#hero.give_item("item name here", false) #for items from the vault 
	var newItem = staticData.items[itemNameStr].duplicate() #make a new instance from the big book of items
	newItem.itemID = global.nextItemID
	global.nextItemID += 1
	equipment[newItem.slot] = newItem #now give it to the matching equipment slot on this hero

func give_existing_item(item): #takes the actual item (use with vault)
	#hero.give_existing_item(actualItemObject)
	equipment[item.slot] = item
	
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
	if (walkable):
		if (walking):
			walking = false
		$touchTimer.set_wait_time(0.5)
		$touchTimer.start()

func _on_heroButton_released():
	if (walkable):
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

func send_home():
	atHome = true
	staffedTo = ""
	staffedToID = -1

func get_archetype():
	#returns string dps, tank, healer
	var archetype = ""
	if (heroClass == "Wizard" || heroClass == "Ranger" || heroClass == "Rogue" || heroClass == "Monk"):
		archetype = "dps"
	elif (heroClass == "Paladin" || heroClass == "Warrior"):
		archetype = "tank"
	elif (heroClass == "Cleric" || heroClass == "Druid"):
		archetype = "healer"
	else:
		archetype = "ERROR"
	return archetype
	
func give_xp(xpNum):
	xp += xpNum
	
func make_level(levelNum):
	if (levelNum > 1):
		for level in range(levelNum):
			level_up()
	
func restore_hp_mana():
	hpCurrent = hp
	manaCurrent = mana
	
func level_up():
	xp = int(0)
	level += int(1)
	baseHp = int(round(baseHp * classLevelModifiers[heroClass].hp))
	baseMana = int(round(baseMana * classLevelModifiers[heroClass].mana))
	baseStrength = int(round(baseStrength * classLevelModifiers[heroClass].strength))
	baseDefense = int(round(baseDefense * classLevelModifiers[heroClass].defense))
	update_hero_stats()
	hpCurrent = hp #refill hp and mana when leveling up 
	manaCurrent = mana  
	
func melee_attack():
	var rawDmg = (equipment["mainHand"].dps * strength) / 2
	var roll = randi()%20+1 #(roll between 1-20)
	if (roll == 1):
		if (battlePrint):
			print("miss!")
		rawDmg = 0
	elif (roll == 20):
		if (battlePrint):
			print("Critical hit! Double damage!")
		rawDmg *= 2
	if (battlePrint):
		print("Returning this raw damage: " + str(rawDmg))
	return rawDmg