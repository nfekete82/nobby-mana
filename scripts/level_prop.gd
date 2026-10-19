@tool
extends StaticBody2D
const Art = preload("res://scripts/art_library.gd")
@export_enum("tree-oak","tree-small","bush") var asset_id := "tree-oak":
	set(value):
		asset_id = value
		if is_inside_tree():
			refresh()

func _ready() -> void:
	refresh()

func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if not ResourceLoader.exists("res://assets/licensed/" + asset_id + "-stand.png"):
		return
	collision_layer = 0 if asset_id == "bush" else 1
	collision_mask = 0
	add_child(Art.sprite_for(asset_id))
	if collision_layer != 0:
		var data: Dictionary = Art.registry().assets[asset_id]
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(data.hitbox[0],data.hitbox[1])
		collider.shape = shape
		collider.position.y = -shape.size.y/2
		add_child(collider)
