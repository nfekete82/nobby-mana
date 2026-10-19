@tool
extends Node2D
@export var map_tiles := Vector2i(40,28)

func _ready() -> void:
	var barriers := get_node_or_null("Barriers")
	if barriers != null:
		barriers.visible = Engine.is_editor_hint()
