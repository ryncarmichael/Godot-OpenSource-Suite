#-------------------------------------------------------------------
# Droofus Games Studio - Cipher Tools 1.0
# Used to obfuscate a string and return it to normal when passed
# the same ciphered sting.
#
# Not unbreakable incryption but enough to make save game file
# difficult to hack
#-------------------------------------------------------------------
# Released Under the MIT open source license (c) 2026
#-------------------------------------------------------------------
extends Node


#---------------------------------------------------
# Cipher Tools
#---------------------------------------------------
func cipher_text(org_text: String) -> String:
	var encrypt_data: String = ""
	var source_data: Array = org_text.to_ascii_buffer()
	for i: int in source_data.size():
		encrypt_data += char(127 - source_data[i])
	encrypt_data = encrypt_data.reverse()
	return encrypt_data
