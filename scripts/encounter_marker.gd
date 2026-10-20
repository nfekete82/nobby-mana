@tool
extends Marker2D
const Art = preload("res://scripts/art_library.gd")
@export_enum("warrior","goblin-scout","goblin-brute") var enemy_kind := "goblin-scout":
	set(value):
		enemy_kind = value
		set_meta("enemy_kind",value)
		if is_inside_tree():
			refresh()

@export_range(1,50) var enemy_level := 1

func _ready() -> void:
	set_meta("enemy_kind",enemy_kind)
	refresh()

func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var id := "enemy-warrior" if enemy_kind == "warrior" else enemy_kind
	var base := "res://assets/licensed/" if enemy_kind == "warrior" else "res://assets/compiled/"
	if ResourceLoader.exists(base+id+"-stand.png"):
		add_child(Art.sprite_for(id))
