#-------------------------------------------------------------------
# Droofus Games - Application Clousure Notification
# Copyright (c) 2026 Droofus Games
#------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
extends Node

#---------------------------------------------------------
# Application Clousure Notification or when close gadget
# is clicked
#---------------------------------------------------------
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_inside_tree():
			get_tree().quit()
