extends Node

const startPhoneme = ["Ast","Ben","Sar","Pi","Pe","Ro","Ric","Quel","Darn","Tur","Vel","Tee","Lass","Pur","Lurd","Lo","Ta","Bors","Cli","Sart","Ern","Kwi","Sot","Das","Yos","Ya","Yrte","Tok","Pe","Oas","Tar","Klo"]
const middlePhoneme = ["","","","","","","","","","","","","","","","","rel","ou","je","taa","lo","nem","vis","eo","ops","tre","er","sut","sur","nes","mir","ve","heil","'po","'tlas","'nio","te","tot","klo","eg","uy","ha","se","'na","'Phlo","tes"]
const endPhoneme = ["den","slon","sion","erg","rel","it","ok","ak","ic","is","'in","ut","'ret","as","eras","in","iot","uet", "rid"]
const space = " "
const lastName = ["Crystalwind","Starlight","Windward","Blackriver","Waters","Fields","Snow", "Ironhammer","Pureheart", "Bluewind", "Tarly", "Aura", "Blackheart", "'Tazra", "Nowell", "Reznor", "Wolfheart", "Azkanbee", "Potts", "Burley", "Kettleblack", "Silverfish", "Eversleep", "Nightwatcher", "Tash", "Glitter", "Stormsteel", "Beerdrinker", "Ragecleaver", "Hills", "Glory", "Earthbloom", "Cloudstrength", "Skullriver", "Prime", "Fury", "Proudbasher", "Bonepunch", "Greenroot", "Battleglade", "Stonewind", "Flint", "Flatgust", "Monsterward", "Fistgloom", "of the Moon", "Cheerheart", "Moltenglaze", "Trueflower", "Rumblemourn", "Bladetaker", "Honorbrought", "Everbend", "Strongdust", "Sacredheart", "Johnson", "the Burly", "the Unwashed", "the Flatulent", "the Funny", "Bonebreaker", "Whitewind", "Oathbreaker", "Oathkeeper", "Par", "of the Eagles", "Bearslayer", "Ratslayer", "Heart", "Thorns", "Everwood", "Finkle", "Blunt", "Blackberry"]
const title = ["the Brave","of the Moths","the Wave Caller","the Hasty","the Idiot","the Tepid","the Careless","the Cautious","the Peacebringer","the Hazard","the Regretful","the Boring","the Sassy","the Burly","the Stalker","the Stormy","the Unwise","the Prudent","the Plaguebringer", "of the Shrubs", "of the Forest"]

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

func _ready():
	pass