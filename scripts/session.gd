extends Node
var selected_class := "monkey"

func choose(character_class: String) -> bool:
	if character_class not in ["monkey","panda"]:
		return false
	selected_class = character_class
	return true

# Shared across both hero classes and scene restarts. Only exploration is saved.
var exploration = preload("res://scripts/exploration.gd").new()

func _exit_tree() -> void:
	exploration.flush()
