extends Node

func _ready():
	pass

func format_time(time):
	var timeFormattedForDisplay = null
	if (time > 3599):
		timeFormattedForDisplay = str(time / 3600) + "h"
	elif (time > 59):
		timeFormattedForDisplay = str(time / 60) + "m"
	else:
		timeFormattedForDisplay = str(time) + "s"
		
	return timeFormattedForDisplay