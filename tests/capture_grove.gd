extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func save(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/grove/"+name+".png")
func run() -> void:
	preload("res://tests/test_support.gd").isolate_exploration(root)
	DirAccess.make_dir_recursive_absolute("res://artifacts/grove")
	root.size = Vector2i(1440,960)
	root.content_scale_size = Vector2i(1440,960)
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	world.hero.position = Vector2(1330,1120)
	world.hero.health = 82
	world.hero.mana = 64
	world.refresh_party()
	await save("reference-world-hud")
	world.hero.position = Vector2(1728,1152)
	await save("bridge")
	world.hero.position = Vector2(1650,480)
	await save("waterfall")
	print("Saved real reference grove, bridge and waterfall screenshots.")
	quit()
