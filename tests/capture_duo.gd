extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func frames(count: int) -> void:
	for index in count:
		await physics_frame

func save(name: String) -> void:
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://artifacts/duo/"+name+".png") == OK)

func walk_review(hero: CharacterBody2D,label: String) -> void:
	var contact := Image.create(192*6,192*2,false,Image.FORMAT_RGBA8)
	for row in 2:
		hero.position = Vector2(2920,1300)
		hero.attack_remaining = 0
		hero.casting_remaining = 0
		var action := "move_right" if row == 0 else "move_up"
		Input.action_press(action)
		for index in 6:
			await frames(5)
			await RenderingServer.frame_post_draw
			var screen := hero.get_global_transform_with_canvas().origin
			var pose := root.get_texture().get_image().get_region(Rect2i(Vector2i(screen)-Vector2i(96,132),Vector2i(192,192)))
			contact.blit_rect(pose,Rect2i(0,0,192,192),Vector2i(index*192,row*192))
		Input.action_release(action)
	contact.save_png("res://artifacts/duo/"+label+"-walk-gameplay.png")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/duo")
	root.size = Vector2i(1280,960)
	root.content_scale_size = Vector2i(1280,960)
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	session.choose("panda")
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	world.hero.position = Vector2(2920,1088)
	await frames(4)
	await save("panda-village")
	var hero = world.hero
	var target = get_nodes_in_group("enemies")[0]
	hero.position = Vector2(2880,1088)
	target.position = Vector2(2950,1088)
	await frames(2)
	hero.primary_action(target.position)
	var contact := Image.create(192*6,192,false,Image.FORMAT_RGBA8)
	for index in 6:
		await frames(1 if index == 0 else 4)
		await RenderingServer.frame_post_draw
		var screen: Vector2 = hero.get_global_transform_with_canvas().origin
		var pose := root.get_texture().get_image().get_region(Rect2i(Vector2i(screen)-Vector2i(96,132),Vector2i(192,192)))
		contact.blit_rect(pose,Rect2i(0,0,192,192),Vector2i(index*192,0))
	contact.save_png("res://artifacts/duo/panda-sword-gameplay.png")
	await save("panda-combat")
	await walk_review(hero,"panda")
	world.queue_free()
	await frames(4)
	session.choose("monkey")
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	world.hero.summon_skeleton()
	await frames(76)
	await save("monkey-cottage")
	await walk_review(world.hero,"monkey")
	world.hero.position = Vector2(2144,2190)
	await frames(4)
	await save("southern-woodland")
	print("Saved actual panda village/sword, bearded monkey and expanded woodland gameplay.")
	quit()
