@tool
extends Node2D
@export var include_goblin_camp := true
@export var map_tiles := Vector2i(40,28)

func _ready() -> void:
	var barriers := get_node_or_null("Barriers")
	if barriers != null:
		barriers.visible = Engine.is_editor_hint()

	if Engine.is_editor_hint() and include_goblin_camp and not has_node("GoblinCampPreview"):
		var preview: Node2D = load("res://scenes/encounters/forest_goblins.tscn").instantiate()
		preview.name = "GoblinCampPreview"
		add_child(preview)
