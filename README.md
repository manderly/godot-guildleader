# godot-guildleader

# Set up
On Mac:
1. Download the latest Godot release. 
2. Place the Godot binary in /usr/local/bin and make sure it is called godot 
3. In terminal. create bash_profile file if not exist;
```touch ~/.bash_profile```
4. Open file with TextEdit;
```open -a TextEdit ~/.bash_profile```

5. Paste this export ```PATH=/usr/local/bin:$PATH``` into TextEdit. 
6. Save and close.
7. Apply changes:
```source ~/.bash_profile```
8. Create symlink for Godot binary
```ln -s /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot```
9. Now you can use godot from the command line, like so:
```$: godot```
