#-------------------------------------------------------------------
# Droofus Games Studio - File Tools Library - 1.1
#
# A useful set of file and directory tools
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
extends Node

#---------------------------------------------------
# File Tools
#---------------------------------------------------
func get_directory_listing(path: String, extension: String) -> PackedStringArray:
	var files: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(path)

	if not dir:
		print_rich("[color=red][b]ERROR[/b][/color]: An error occurred when trying to access the path: " + path)
		return []

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(extension):
				files.append(file_name)
		file_name = dir.get_next()
	files.sort()

	return files


func load_string_array(path: String, filename: String, allowEmpty: bool) -> PackedStringArray:
	if get_file_exists(path, filename):
		return get_file_data(path, filename).split("\n",allowEmpty)
	else:
		print_rich("[color=red][b]ERROR[/b][/color]: File not found: " + filename)
		return []


func get_file_exists(path: String, fileName: String) -> bool:
	if DirAccess.get_files_at(path).find(fileName) > -1:
		return true
	return false


func get_file_data(path: String, fileName: String) -> String:
	return FileAccess.get_file_as_string(path + fileName)


func save_file(path: String, filename: String, filedata: String) -> void:
	var file: FileAccess = FileAccess.open(path + filename, FileAccess.WRITE)
	if not file:
		print_rich("[color=red][b]ERROR[/b][/color]: Error occurred when trying to save the file: " + filename)
		return

	file.store_string(filedata)
	var error: int = file.get_error()
	file.close()
	if error != OK:
		print_rich("[color=red][b]ERROR[/b][/color]: Error occurred when trying to save the file: " + filename)


func is_directory(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)
