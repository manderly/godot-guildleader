# Parsely Tool

Developed for Guild Leader project (personal project)
Allows user to export game data (recipes, items, loot tables, etc.) from Google Sheets into a format Godot engine can use. 

To use:
1. Export .json from Google Sheets using exporter add-on 
2. Place .json files in parsely/names, parsely/staticData, parsely/timedNodeData, etc. 
3. In Terminal, ```node parsely.js```
4. Exported .gd files are placed directly in gameData folder

Todo:
- reduce the number of steps involved with saving files from Google Sheets into the project and exporting
- verify that it's okay to have parsely sitting inside the godot project folder

Notes:
- json file to process must be an array of objects

Sample output: 
```
STARTING GODOT JSON PARSELY - Guild Leader edition 3/27/2019

PROCESSING COLOR TINT DATA
Looking in..../tints/
Processing tints.json
Done (tint data)

PROCESSING TIMED NODE DATA
Looking in..../timedNodeData/
Skipping .DS_Store
Processing camps.json
Processing harvesting.json
Processing tradeskills.json
Done (timed node data assembly)

PROCESSING NAMES ARRAY DATA
Looking in..../names/
Processing humanFemale.json
Processing humanMale.json
Processing surnamesCleric.json
Processing surnamesHuman.json
Processing surnamesNature.json
Processing surnamesRogue.json
Processing surnamesWarrior.json
Processing surnamesWizard.json
Done (names data)

PROCESSING STATIC DATA
Looking in..../staticData/
Skipping .DS_Store
Processing heroStats.json
Processing items.json
Processing levelXpData.json
Processing loadouts.json
Processing lootGroups.json
Processing lootTables.json
Processing mobs.json
Processing perks.json
Processing quests.json
Processing recipes.json
Processing roomTypes.json
Processing spawnTables.json
Done (static data)

PROCESSING DYNAMIC DATA
Done (dynamic data)
```
