extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func save(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/minimap/"+name+".png")
func freeze(world: Node2D) -> void:
	world.hero.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
func capture() -> void:
	var session := preload("res://tests/test_support.gd").isolate_exploration(root)
	DirAccess.make_dir_recursive_absolute("res://artifacts/minimap")
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	freeze(world)
	await save("fresh-area")
	for point in [Vector2(1360,1120),Vector2(1540,1152),Vector2(1728,1152),Vector2(1960,1152),Vector2(2144,1120),Vector2(2440,1120),Vector2(2610,1100)]:
		world.hero.position = point
		world.minimap.update_exploration()
	world.hero.position = Vector2(1728,1152)
	world.minimap.update_exploration()
	await save("explored-route")
	world.queue_free()
	await frames(3)
	session.choose("panda")
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	freeze(world)
	await save("panda-shared-map")
	print("Saved actual compact HUD and black/explored minimap screenshots without changing user saves.")
	quit()
