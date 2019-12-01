# Parsely Tool

Developed for Guild Leader project (December 2018)
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
