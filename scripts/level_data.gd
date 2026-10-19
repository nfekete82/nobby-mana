@tool
extends Node2D
@export var include_goblin_camp := true
@export var map_tiles := Vector2i(56,40)
@export var include_village := true

func _ready() -> void:
	var barriers := get_node_or_null("Barriers")
	if barriers != null:
		barriers.visible = Engine.is_editor_hint()

	if Engine.is_editor_hint() and include_goblin_camp and not has_node("GoblinCampPreview"):
		var preview: Node2D = load("res://scenes/encounters/forest_goblins.tscn").instantiate()
		preview.name = "GoblinCampPreview"
		add_child(preview)

	# Unowned instances keep the hand-authored base scene unchanged on save.
	# Edit the district itself in scenes/levels/woodland_village.tscn.
	if include_village and not has_node("WoodlandVillage"):
		var village: Node2D = load("res://scenes/levels/woodland_village.tscn").instantiate()
		village.name = "WoodlandVillage"
		add_child(village)
