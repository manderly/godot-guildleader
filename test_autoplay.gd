# test_autoplay.gd
# Runs through tradeskills and reports data on combines, skillups, etc.
extends SceneTree

var autoplay = load("res://autoplay_node.gd").new()

func _init():
	autoplay._ready()
	quit()