/* Parsely v.0.1
Developed for Guild Leader project (December 2018)

To use: place .json files in parsely/names, parsely/staticData, parsely/timedNodeData, etc.

In Terminal:
   node parsely.js

Exported .gd files are placed directly in gameData folder.

Todo:
-reduce the number of steps involved with saving files from Google Sheets into the project and exporting
- verify that it's okay to have parsely sitting inside the godot project folder

Notes:
- json file to process must be an array of objects
*/

console.log("\n STARTING GODOT JSON PARSELY - Guild Leader edition 3/27/2019 \n");
var fs = require("fs");
var oneHugeString = "extends Node\n";
var filenameRegEx = '^([a-zA-Z]+)';

// Collect instances of things like...
// - ingredients in recipes having no count associated with them
// - items having null stats
// ... so the user can fix them in the data spreadsheet instead of having to find them in-game.
var staticDataWarnings = [];

//these get fed into dynamic vars but they are built here
var playerTradeskillItems = {};
var playerQuestItems = {};

//STATIC DATA - same across all players/all saves
const staticDataFolder = './staticData/'
fs.readdir(staticDataFolder, (err, files) => {
  console.log("PROCESSING STATIC DATA");
  oneHugeString = "extends Node\n";
  console.log("Looking in..." + staticDataFolder);
  files.forEach(file => {
    var arr = [];
    if ((/\.(json)$/i).test(file)) { //if it's json
        console.log("Processing " + file);
        var formatted = {};
        var fromJSON = JSON.parse(fs.readFileSync(staticDataFolder + file, 'utf8'));
        for (var value of fromJSON) {
            var key = "";
            if (file == "items.json") {
                key = value["name"];
                value["itemID"] = -1;
                value["improved"] = false;
                value["improvement"] = "";
                formatted[key] = value;

                if (value["itemType"] == "tradeskill") {
                    playerTradeskillItems[key] = {
                        "count": 0,
                        "name":key,
                        "icon":value.icon,
                        "seen":false,
                        "consumable":value.consumable
                        };
                } else if (value["itemType"] == "quest") { //or put it in the quest items dictionary
                    playerQuestItems[key] = {
                        "count":0,
                        "name":key,
                        "icon":value.icon,
                        "seen":false,
                        "consumable":value.consumable
                        };
                } else {
                    //it only has class restrictions if it's NOT a tradeskill or quest item
                    var classRestrictionsArray = []
                    classRestrictionsArray.push(formatted[key].classRestriction1);

                    if (formatted[key].classRestriction2 != "") {
                        classRestrictionsArray.push(formatted[key].classRestriction2);
                    }

                    if (formatted[key].classRestriction3 != "") {
                        classRestrictionsArray.push(formatted[key].classRestriction3);
                    }

                    if (formatted[key].classRestriction4 != "") {
                        classRestrictionsArray.push(formatted[key].classRestriction4);
                    }

                    if (formatted[key].classRestriction5 != "") {
                        classRestrictionsArray.push(formatted[key].classRestriction5);
                    }

                    formatted[key].classRestrictions = classRestrictionsArray;
                }
            } else if (file == "mobs.json") {
                key = value["mobName"];
                value.hpCurrent = value.hp;
                value.manaCurrent = value.mana;
                value.dead = false;
                formatted[key] = value;
            } else if (file == "spawnTables.json") {
                key = value["tableName"];
                formatted[key] = value;
            } else if (file == "lootTables.json") {
                key = value["lootTableName"];
                formatted[key] = value;
            } else if (file == "quests.json") {
                key = value["questId"]; //a string, ie: "forest01"
                value.timesRun = 0;
                formatted[key] = value;
            } else if (file == "recipes.json") {
                // look for instances of ingredient assigned but no quantity
                if (value["ingredient1"] && value["ingredient1Quantity"] === null) {
                    staticDataWarnings.push("Recipe for " + value["recipeName"] + " is missing " + value["ingredient1"] + " quantity");
                }
                if (value["ingredient2"] && value["ingredient2Quantity"] === null) {
                    staticDataWarnings.push("Recipe for " + value["recipeName"] + " is missing " + value["ingredient2"] + " quantity");
                }
                if (value["ingredient3"] && value["ingredient3Quantity"] === null) {
                    staticDataWarnings.push("Recipe for " + value["recipeName"] + " is missing " + value["ingredient3"] + " quantity");
                }
                if (value["ingredient4"] && value["ingredient4Quantity"] === null) {
                    staticDataWarnings.push("Recipe for " + value["recipeName"] + " is missing " + value["ingredient4"] + " quantity");
                }

                arr.push(value);
                formatted = arr;
            } else if (file == "levelXpData.json") {
                key = value["level"];
                formatted[key] = value;
            } else if (file == "perks.json") {
                key = value["perkId"];
                formatted[key] = value;
            } else if (file == "heroStats.json") {
                key = value["charClass"];
                formatted[key] = value;
            } else if (file == "lootGroups.json") {
                key = value["lootGroupName"];
                formatted[key] = value;
            } else if (file == "roomTypes.json") {
                //these are just supposed to be arrays of objects or strings, ie: var heroStats = ["{warrior:{hp:123,mana:0}...","",""]
                arr.push(value);
                formatted = arr;
            } else if (file == "loadouts.json") {
                key = value["loadoutId"];
                formatted[key] = value;
            } else {
                console.log("Found but did not process this .json file: " + file);
            }
        }
        var justFilename = file.match(filenameRegEx); //returns an array of potential matches [ 'items', 'items', index: 0, input: 'items.json' ]
        oneHugeString += "var "+justFilename[0]+"="+JSON.stringify(formatted)+"\n"; //the match we need is always at index 0 though
    } else {
        console.log("Skipping " + file);
    }
  });

    // print any warnings
    if (staticDataWarnings.length) {
        console.log("\nStatic data warnings:");
        for (i = 0; i < staticDataWarnings.length; i++) {
            console.log(staticDataWarnings[i]);
        }
    } else {
        console.log("Static data generated no warnings!");
    }

    //write the static data file
    fs.writeFileSync("../gameData/staticData.gd", oneHugeString);
    console.log("DONE (static data)\n");

    //now write the dynamic data file
    //add on these two other objects we built earlier
    console.log("PROCESSING DYNAMIC DATA");
    var dynamicDataString = "extends Node\n";

    dynamicDataString+="var playerTradeskillItems="+JSON.stringify(playerTradeskillItems)+"\n";
    dynamicDataString+="var playerQuestItems="+JSON.stringify(playerQuestItems)+"\n";
    fs.writeFileSync("../gameData/dynamicData.gd", dynamicDataString);
    console.log("DONE (dynamic data)\n");

});

//process tints from JSON objects to Godot-friendly Colors
const tintsFolder = './tints/';
fs.readdir(tintsFolder, (err, files) => {
    console.log("PROCESSING COLOR TINT DATA");
    oneHugeString = "extends Node\n";
    console.log("Looking in..." + tintsFolder);
    files.forEach(file => {
        if ((/\.(json)$/i).test(file)) { //if it's json
            console.log("Processing " + file);
            var fromJSON = JSON.parse(fs.readFileSync(tintsFolder + file, 'utf8'));
            for (var value of fromJSON) {
                //divide each number by 255 to get a Godot-friendly value
                var red = parseFloat(value.red/255).toFixed(3);
                var green = parseFloat(value.green/255).toFixed(3);
                var blue = parseFloat(value.blue/255).toFixed(3);
                var alpha = parseFloat(value.alpha/100).toFixed(2);
                oneHugeString += "var "+value.tintName+" = Color("+red+", "+green+", "+blue+", "+alpha+")\n";
            }
        }
    });
    fs.writeFileSync("../gameData/tints.gd", oneHugeString);
    console.log("DONE (tint data)\n");
});

//name files are already exported as arrays, so we just need this tool to turn them into a gd file with vars
const namesFolder = './names/';
fs.readdir(namesFolder, (err, files) => {
    console.log("PROCESSING NAMES ARRAY DATA");
    oneHugeString = "extends Node\n";
    console.log("Looking in..." + namesFolder);
    files.forEach(file => {
        if ((/\.(json)$/i).test(file)) { //if it's json
            console.log("Processing " + file);
            var namesArr = fs.readFileSync(namesFolder + file, 'utf8');
            var justFilename = file.match(filenameRegEx); //returns an array of potential matches [ 'items', 'items', index: 0, input: 'items.json' ]
            oneHugeString += "var "+justFilename[0]+"="+namesArr+"\n";
        }
    });
    fs.writeFileSync("../gameData/names.gd", oneHugeString);
    console.log("DONE (names data)\n");
});

//TIMED NODE DATA - these vary by save
const timedNodeDataFolder = './timedNodeData/';
fs.readdir(timedNodeDataFolder, (err, files) => {
    console.log("PROCESSING TIMED NODE DATA");
    oneHugeString = "extends Node\n";
    console.log("Looking in..." + timedNodeDataFolder);
    files.forEach(file => {
        if ((/\.(json)$/i).test(file)) { //if it's json
            console.log("Processing " + file);
            var formatted = {};
            var fromJSON = JSON.parse(fs.readFileSync(timedNodeDataFolder + file, 'utf8'));
            for (var value of fromJSON) {
                var key = "";
                if (file == "tradeskills.json") {
                    key = value["tradeskill"];
                    value.hero = null;
                    value.inProgress = false;
                    value.readyToCollect = false;
                    value.wildcardItemOnDeck = null;
                    value.recipes = [];
                    value.selectedRecipe = null;
                    value.currentlyCrafting = {
                        "conversion":false,
                        "moddingAnItem":false,
                        "wildcardItem":null,
                        "name":"",
                        "statImproved":"",
                        "statIncrease":"",
                        "totalTimeToFinish":"",
                        "endTime":-1
                    }
                    formatted[key] = value;
                } else if (file == "harvesting.json") {
                    key = value["harvestingId"];
                    value.hero = null;
                    value.endTime = -1;
                    value.inProgress = false;
                    value.readyToCollect = false;
                    value.timesRun = 0;
                    value.lootWon = {
                        "prizeItem1":null,
                        "prizeQuantity":0
                    }
                    formatted[key] = value;
                } else if (file == "camps.json") {
                    key = value["campId"];
                    //breaks manual selection if done in camp.gd
                    value.heroes = []
                    for (var i in value.groupSize) {
                        value.heroes.push(null);
                    }

                    value.spawnPointData = {
                        "spawnPoint1TableName":value.spawnPoint1,
                        "spawnPoint2TableName":value.spawnPoint2,
                        "spawnPoint3TableName":value.spawnPoint3
                    };
                    //we now have an array of spawn point table names
                    value.endTime = -1;
                    value.inProgress = false;
                    value.readyToCollect = false;
                    value.timesRun = 0;
                    value.campHeroesSelected = 0;
                    value.selectedDuration = 0;
                    value.enableButton = "";
                    value.campOutcome = {};
                    formatted[key] = value;
                //to set a camp: global.currentCamp = global.campData["camp_forest01"]
            } else {
                console.log("Found but did not process this .json file: " + file);
            }
        }
        var justFilename = file.match(filenameRegEx); //returns an array of potential matches [ 'items', 'items', index: 0, input: 'items.json' ]
        oneHugeString += "var "+justFilename[0]+"="+JSON.stringify(formatted)+"\n"; //the match we need is always at index 0 though
    } else {
        console.log("Skipping " + file);
    }
  });
    //finally, build the training room data structure
    var trainingObj = {};
    for (var i = 0; i < 6; i++) {
        var key = "training"+i
        trainingObj[key] = {
            "inProgress":false,
            "readyToCollect":false,
            "endTime":-1,
            "hero":null,
            "levelToGrant":0,
        };
    }
    oneHugeString += "var training="+JSON.stringify(trainingObj)+"\n";
    fs.writeFileSync("../gameData/timedNodeData.gd", oneHugeString);
    console.log("Done (timed node data assembly)\n");
});

