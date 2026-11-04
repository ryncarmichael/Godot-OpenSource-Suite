#-------------------------------------------------------------------
# Droofus Games Studio - Bookmark Browser 1.0
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
@tool
extends EditorPlugin

# Dock reference.
var dock: EditorDock
var dock_content: bookmark_browser = preload("./bookmarks_scene.tscn").instantiate()

# Plugin initialization.
func _enter_tree() -> void:
	dock = EditorDock.new()
	dock.title = "Bookmarks"
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	dock.add_child(dock_content)
	add_dock(dock)

# Plugin clean-up.
func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
	dock = null
