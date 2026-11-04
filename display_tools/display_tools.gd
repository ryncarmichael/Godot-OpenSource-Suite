#-------------------------------------------------------------------
# Droofus Games Studio - Droofus Display Controls
#
# A useful set of file and directory tools
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------

extends Node

# Time to wait after splash screen, to allow proper window changes
# and startup script to finish running
var bootSpashTime: int = 1

func _ready() -> void:
	await get_tree().create_timer(bootSpashTime).timeout
	if DroofusDefaults.resizeWindowForBestFit:
		set_display_size()
	DroofusDefaults.postSplash = true
	DroofusDefaults.droofus_postsplashscreen.emit()  # Tell the main game screen to start


func set_display_size() -> void:
	var scale_factor: int = DisplayServer.screen_get_usable_rect(DisplayServer.SCREEN_OF_MAIN_WINDOW).size.y / 1080
	if DisplayServer.window_get_size().y != int(1080 * scale_factor):
		DisplayServer.window_set_size(Vector2(1920 * scale_factor, 1080 * scale_factor), 0)

		var posx: int = (DisplayServer.screen_get_usable_rect(DisplayServer.SCREEN_OF_MAIN_WINDOW).size.x / 2)
		posx -= (1920 * scale_factor) / 2
		var posy: int= (DisplayServer.screen_get_usable_rect(DisplayServer.SCREEN_OF_MAIN_WINDOW).size.y / 2)
		posy -= (1080 * scale_factor) / 2
		DisplayServer.window_set_position(Vector2(posx,posy),0)
