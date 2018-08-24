extends Node

const startPhoneme = ["Ast","Ben","Sar","Pi","Pe","Ro","Ric","Quel","Darn","Tur","Vel","Tee","Lass","Pur","Lurd","Lo","Ta","Bors","Cli","Sart","Ern","Kwi","Sot","Das","Yos","Ya","Yrte","Tok","Pe","Oas","Tar","Klo"]
const middlePhoneme = ["","","","","","","","","","rel","ou","je","taa","lo","nem","vis","eo","ops","tre","er","sut","sur","nes","mir","ve","heil","'po","'tlas","'nio","te","tot","klo","eg","uy","ha","se","'na","'Phlo","tes"]
const endPhoneme = ["den","slon","sion","erg","rel","it","ok","ak","ic","is","'in","ut","'ret","as","eras","in","iot","uet"]
const space = " "
const lastName = ["Crystalwind","Waters","Fields","Snow","Ironhammer", "Pureheart", "the Brave", "the Wave Caller", "Bluewind", "Tarly", "the Tepid", "Aura", "Blackheart", "'Tazra", "Nowell", "Reznor", "Wolfheart", "Azkanbee", "Potts", "Burley", "Kettleblack", "Silverfish", "of the Vale", "Eversleep", "Nightwatcher", "the Stalker", "Tash", "the Sassy", "Glitter", "Stormsteel", "Beerdrinker", "Ragecleaver", "Hills", "Glory", "the Peacebringer", "Earthbloom", "Cloudstrength", "Skullriver", "Prime", "Fury", "Proudbasher", "Bonepunch", "Greenroot", "Battleglade", "Stonewind", "Flint", "Flatgust", "Monsterward", "Fistgloom", "of the Moon", "Cheerheart", "Moltenglaze", "Trueflower", "Rumblemourn", "the Snakefriend", "Bladetaker", "Honorbrought", "Everbend", "Strongdust", "Sacredheart", "Johnson", "the Burly"]

static func generate():
	var startRand = round(rand_range(0, startPhoneme.size() - 1))
	var middleRand = round(rand_range(0, middlePhoneme.size() - 1))
	var endRand = round(rand_range(0, endPhoneme.size() - 1))
	var lastRand = round(rand_range(0, lastName.size() - 1))
	var completeName = startPhoneme[startRand] + middlePhoneme[middleRand] + endPhoneme[endRand] + space + lastName[lastRand]
  	
	return completeName

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass