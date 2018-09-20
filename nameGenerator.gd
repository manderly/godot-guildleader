extends Node

const startPhoneme = ["Ast","Ben","Sar","Pi","Pe","Ro","Ric","Quel","Darn","Tur","Vel","Tee","Lass","Pur","Lurd","Lo","Ta","Bors","Cli","Sart","Ern","Kwi","Sot","Das","Yos","Ya","Yrte","Tok","Pe","Oas","Tar","Klo"]
const middlePhoneme = ["","","","","","","","","","","","","","","","","rel","ou","je","taa","lo","nem","vis","eo","ops","tre","er","sut","sur","nes","mir","ve","heil","'po","'tlas","'nio","te","tot","klo","eg","uy","ha","se","'na","'Phlo","tes"]
const endPhoneme = ["den","slon","sion","erg","rel","it","ok","ak","ic","is","'in","ut","'ret","as","eras","in","iot","uet", "rid"]
const space = " "
const lastName = ["Crystalwind","Starlight","Windward","Blackriver","Waters","Fields","Snow", "Ironhammer","Pureheart", "Bluewind", "Tarly", "Aura", "Blackheart", "'Tazra", "Nowell", "Reznor", "Wolfheart", "Azkanbee", "Potts", "Burley", "Kettleblack", "Silverfish", "Eversleep", "Nightwatcher", "Tash", "Glitter", "Stormsteel", "Beerdrinker", "Ragecleaver", "Hills", "Glory", "Earthbloom", "Cloudstrength", "Skullriver", "Prime", "Fury", "Proudbasher", "Bonepunch", "Greenroot", "Battleglade", "Stonewind", "Flint", "Flatgust", "Monsterward", "Fistgloom", "of the Moon", "Cheerheart", "Moltenglaze", "Trueflower", "Rumblemourn", "Bladetaker", "Honorbrought", "Everbend", "Strongdust", "Sacredheart", "Johnson", "the Burly", "the Unwashed", "the Flatulent", "the Funny", "Bonebreaker", "Whitewind", "Oathbreaker", "Oathkeeper", "Par", "of the Eagles", "Bearslayer", "Ratslayer", "Heart", "Thorns", "Everwood", "Finkle", "Blunt", "Blackberry"]
const title = ["the Brave","of the Moths","the Wave Caller","the Hasty","the Idiot","the Tepid","the Careless","the Cautious","the Peacebringer","the Hazard","the Regretful","the Boring","the Sassy","the Burly","the Stalker","the Stormy","the Unwise","the Prudent","the Plaguebringer", "of the Shrubs", "of the Forest"]

const guildNames = ["Faith and Fury", "Keepers of the Night", "Metal and Might", "Swords and Storms", "Magic and Mayhem", "Unconquered Legacy", "The Unbreakables", "Fires of Destiny", "Dark Destiny", "Keepers of Lore", "Old Guard Outlaws", "Midnight Empire", "The Silver Blade", "The Riverlords", "Visions of Victory", "Anomaly", "Dawn Soldiers", "Heroes of the Sword", "Mercenaries of the Coast", "High Crusaders", "Society of Nobles", "The Stonefists", "Forsaken Blades", "The Promised Ones", "Searing Force", "Stoneguard", "Guardians of the Keep", "Wisdom", "Mead and Maidens", "The Unfavored Sons", "Heirs of Fortune", "Darkbane", "The Lost Company", "Riders of the Dawn", "Truth and Honor", "The Great Dividers", "The Planeswalkers", "The Ancients", "Thunderforce", "Lightstalkers", "Unseen Order", "Chaosbringers", "Skunk Queens", "Dragonhunters", "Steel and Fury"]

static func generate():
	var startRand = round(rand_range(0, startPhoneme.size() - 1))
	var middleRand = round(rand_range(0, middlePhoneme.size() - 1))
	var endRand = round(rand_range(0, endPhoneme.size() - 1))
	var lastRand = round(rand_range(0, lastName.size() - 1))
	var completeName = startPhoneme[startRand] + middlePhoneme[middleRand] + endPhoneme[endRand] + space + lastName[lastRand]
  	
	#rare chance at a hero being created with a title already in place
	var titleRand = round(rand_range(0,100))
	if (titleRand > 95):
		var titleRandIndex = round(rand_range(0,title.size() - 1))
		completeName += " " + title[titleRandIndex]
		
	return completeName

static func generateGuildName():
	var guildNameRand = round(rand_range(0, guildNames.size() - 1))
	var completeGuildName = guildNames[guildNameRand]
	return completeGuildName
	
func _ready():
	pass
	