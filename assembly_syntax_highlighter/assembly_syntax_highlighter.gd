#-------------------------------------------------------------------
# Droofus Games Studio - Assembly Language Syntax Highlighter 3.4
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
@tool
extends EditorPlugin

const TEXTFILE_EXTENSIONS_SETTING: String = "docks/filesystem/textfile_extensions"

var assembly_highlighter:AssemblySyntaxHighlighter

func _enable_plugin() -> void:
	_add_textfile_extension("asm")

func _disable_plugin() -> void:
	_remove_textfile_extension("asm")


func _enter_tree() -> void:
	assembly_highlighter = AssemblySyntaxHighlighter.new()
	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	script_editor.register_syntax_highlighter(assembly_highlighter)


func _exit_tree() -> void:
	if is_instance_valid(assembly_highlighter):
		var script_editor: ScriptEditor = EditorInterface.get_script_editor()
		script_editor.unregister_syntax_highlighter(assembly_highlighter)
		assembly_highlighter = null


func _add_textfile_extension(extension: String) -> void:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	var textfile_extensions: String = settings.get_setting(TEXTFILE_EXTENSIONS_SETTING)
	textfile_extensions += "," + extension
	settings.set_setting(TEXTFILE_EXTENSIONS_SETTING, textfile_extensions)


func _remove_textfile_extension(extension: String) -> void:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	var textfile_extensions: String = settings.get_setting(TEXTFILE_EXTENSIONS_SETTING)
	textfile_extensions = textfile_extensions.replace("," + extension, "")
	print(textfile_extensions)
	settings.set_setting(TEXTFILE_EXTENSIONS_SETTING, textfile_extensions)


class AssemblySyntaxHighlighter extends EditorSyntaxHighlighter:

	var libraryPath: String = "res://droofus/core/libs/"
	var addonPath: String = "res://addons/assembly_syntax_highlighter/"
	var reservedwords: PackedStringArray = load_string_array(libraryPath, "reservedwords.lib", false)
	var constants: PackedStringArray = load_string_array(libraryPath, "constants.lib", false)
	var constantsModifiedTime: int = 0
	var registers: PackedStringArray = load_string_array(libraryPath, "registers.lib", false)
	var directives: PackedStringArray  = load_string_array(libraryPath, "directives.lib", false)
	var SyntaxColors: Resource = ResourceLoader.load(addonPath + "syntax_colors.tres")

	func _get_name() -> String:
		return "Assembly"

	func _get_supported_languages() -> PackedStringArray:
		return ["Assembly"]

	func _get_line_syntax_highlighting(line: int) -> Dictionary:
		check_for_hot_load()

		var color_map: Dictionary = { "Color": SyntaxColors.default }
		var text_editor: TextEdit = get_text_edit()
		var codeLine: String = text_editor.get_line(line)
		var words: PackedStringArray = codeLine.strip_edges().split(" ",false)

		# Full Line Comments just return green
		if codeLine.strip_edges().begins_with(";"):
			color_map[0] = { "color": SyntaxColors.comments }
			return color_map

		if words.size(): # Make sure the line is not blank

			if words[0].ends_with(":"):
				color_map[codeLine.find(words[0])] = { "color": SyntaxColors.labels } # Labels
			elif reservedwords.has(words[0]):
				color_map[codeLine.find(words[0])] = { "color": SyntaxColors.reserved_words }  # Reserved Words
			elif directives.has(words[0]):
				color_map[codeLine.find(words[0])] = { "color": SyntaxColors.compiler_directives }  # Directives

			if words.size() > 1:
				color_map[codeLine.find(" ") + 1] = { "color": SyntaxColors.default } # Blank remainder of line

				if not codeLine.contains(char(34)):
					codeLine = codeLine.replacen(","," ")
					words = codeLine.strip_edges().split(" ",false)

					for i: int in range(1, words.size()):
						if words[i].begins_with(";"): break

						if constants.has(words[i]): # Constants
							color_map[codeLine.find(" " + words[i])+1] = { "color": SyntaxColors.constants }

						var numStr: String = words[i]
						if numStr.begins_with("#"):
							numStr = numStr.right(numStr.length() - 1)
						if numStr.is_valid_float() or numStr.is_valid_int():
							color_map[codeLine.find(" " + words[i])+1] = { "color": SyntaxColors.numbers }

						if registers.has(words[i]):
							color_map[codeLine.find(" " + words[i])+1] = { "color": SyntaxColors.registers }

				else:
					if codeLine.count(char(34)) % 2 == 0: # Make sure we have closing quotes
						if not codeLine.contains(";") or not codeLine.find(";") < codeLine.find(char(34)):
							color_map[codeLine.find(char(34))] = { "color": SyntaxColors.quoted_text }
							color_map[codeLine.rfind(char(34))+1] = { "color": SyntaxColors.default }

				# Inline comments
				if codeLine.contains(";"):
					color_map[codeLine.find(";")] = { "color": SyntaxColors.comments }


		return color_map



	func check_for_hot_load() -> void:
		if get_file_modified_time(libraryPath , "constants.lib") != constantsModifiedTime:
			constants = load_string_array(libraryPath, "constants.lib", false)
			constantsModifiedTime = get_file_modified_time(libraryPath, "constants.lib")
			clean_up_constants()


	func clean_up_constants() -> void:
		constantsModifiedTime = get_file_modified_time(libraryPath, "constants.lib")
		for i: int in constants.size(): # Need to do a little cleanup on the constants
			constants[i] = constants[i].split(",",false)[0]


	func load_string_array(path: String, fileName: String, allowEmpty: bool) -> PackedStringArray:
		if get_file_exists(path, fileName):
			if fileName == "constants.lib":
				clean_up_constants()
			return get_file_data(path, fileName).split("\n",allowEmpty)
		else:
			print_rich("[color=red][b]ERROR[/b][/color]: Library File Not Found : " + fileName)
			return []


	func get_file_modified_time(path: String, fileName: String) -> int:
		return FileAccess.get_modified_time(path + fileName)


	func get_file_exists(path: String, fileName: String) -> bool:
		if DirAccess.get_files_at(path).find(fileName) > -1:
			return true
		return false


	func get_file_data(path: String, fileName: String) -> String:
		return FileAccess.get_file_as_string(path + fileName)
