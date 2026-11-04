#-------------------------------------------------------------------
# Droofus Games Studio - Bookmark Browser 1.0
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
@tool
extends Control

class_name bookmark_browser

@onready var bookmark_list: ItemList = $bookmark_list
@onready var title_bookmars_browser: Label = $Header/HBoxContainer/title_bookmars_browser
@onready var sort_bookmarks: CheckButton = $Header/HBoxContainer/sort_bookmarks
@onready var include_user_bookmarks: CheckButton = $Footer/include_user_bookmarks
@onready var bookmarked_lines_numbers: PackedInt32Array
@onready var bookmarked_lines_text: PackedStringArray


func _ready() -> void:
	# Change to suit
	title_bookmars_browser.text = "Assembly Functions"


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if Engine.get_process_frames() % 300 == 0: # Five seconds
			update_function_list()


func update_function_list() -> void:
	if EditorInterface.get_script_editor().get_current_editor() != null:
		var code_editor: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
		if code_editor.get_bookmarked_lines() != bookmarked_lines_numbers:
			bookmarked_lines_numbers = code_editor.get_bookmarked_lines()
			if bookmarked_lines_numbers.size() > 0:
				bookmark_list.clear()
				bookmarked_lines_text.clear()
				for i: int in bookmarked_lines_numbers.size():
					var lineText: String = code_editor.get_line(bookmarked_lines_numbers[i])
					lineText = lineText.strip_escapes().strip_edges()

					#Adjust the logic here to suit your top tier bookmarks to include
					if lineText.contains(":") and not lineText.begins_with(";") and not lineText.begins_with("."):
						lineText = lineText.left(lineText.find(":"))
						bookmark_list.add_item(lineText)
						bookmark_list.set_item_custom_fg_color(bookmark_list.item_count-1, Color(1.0, 1.0, 1.0, 0.75))
					elif include_user_bookmarks.button_pressed:
						bookmark_list.add_item(lineText)
						bookmark_list.set_item_custom_fg_color(bookmark_list.item_count-1, Color.DARK_GOLDENROD)

					#Needed for remapping the text back to the linenumber if sorted
					bookmarked_lines_text.append(lineText)

				if sort_bookmarks.button_pressed:
					bookmark_list.sort_items_by_text()

		elif bookmark_list.item_count > 0 and code_editor.get_bookmarked_lines().size() == 0:
			bookmark_list.clear()


func _on_item_list_item_selected(index: int) -> void:
	if Engine.is_editor_hint():
		if EditorInterface.get_script_editor().get_current_editor() != null:
			var code_editor: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
			if bookmarked_lines_numbers.size():
				var lineIndex: int = bookmarked_lines_numbers[bookmarked_lines_text.find(bookmark_list.get_item_text(index))]
				code_editor.set_caret_line(lineIndex)


func _button_toggled(_toggled_on: bool) -> void:
	bookmarked_lines_numbers.clear()
	bookmarked_lines_text.clear()
