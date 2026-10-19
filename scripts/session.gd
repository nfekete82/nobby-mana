extends Node
var selected_class := "shaman"

func choose(character_class: String) -> bool:
	if character_class not in ["mage","shaman"]:
		return false
	selected_class = character_class
	return true
