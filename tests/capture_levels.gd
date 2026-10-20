extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func freeze(world: Node2D) -> void:
	world.hero.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
func save(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/levels/"+name+".png")
func capture() -> void:
	var session := preload("res://tests/test_support.gd").isolate_exploration(root)
	DirAccess.make_dir_recursive_absolute("res://artifacts/levels")
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	freeze(world)
	await save("larger-view")
	world.hero.gain_experience(180)
	for y in range(1120,3880,100):
		world.hero.position = Vector2(1312,y)
		world.minimap.update_exploration()
	world.hero.position = Vector2(1728,3840)
	world.minimap.update_exploration()
	world.hero.sprite.play("stand")
	await save("south-bridge-level2")
	world.queue_free()
	await frames(3)
	session.choose("panda")
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	freeze(world)
	world.hero.gain_experience(315)
	world.hero.position = Vector2(2656,4490)
	world.minimap.update_exploration()
	world.hero.sprite.play("stand")
	await save("panda-southern-village")
	# Editor-style geography review with the same camera rendering, extra zoom
	# is only for this overview artifact, never the runtime player camera.
	world.hero.position = Vector2(1792,2560)
	var camera: Camera2D = world.hero.get_viewport().get_camera_2d()
	camera.zoom = Vector2(0.15,0.15)
	world.get_node("HUD").hide()
	await save("whole-map-overview")
	print("Saved native gameplay and separate geography overview screenshots.")
	quit()
