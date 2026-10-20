extends Node
var selected_class := "monkey"

func choose(character_class: String) -> bool:
	if character_class not in ["monkey","panda"]:
		return false
	selected_class = character_class
	return true

# Exploration is shared; hero experience is separate for each class.
var exploration = preload("res://scripts/exploration.gd").new()

var progression = preload("res://scripts/progression.gd").new()

func _exit_tree() -> void:
	exploration.flush()
	progression.flush()
