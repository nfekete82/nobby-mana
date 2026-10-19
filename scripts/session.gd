extends Node
var selected_class := "monkey"

func choose(character_class: String) -> bool:
	if character_class not in ["monkey","panda"]:
		return false
	selected_class = character_class
	return true
