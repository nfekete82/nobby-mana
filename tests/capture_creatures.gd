extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func frames(count: int) -> void:
	for index in count:
		await physics_frame

func capture() -> void:
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	session.selected_class = "monkey"
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	var hero = world.hero
	hero.position = Vector2(600,640)
	var shown: Dictionary = {}
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		if enemy.enemy_kind == "goblin-scout" and not shown.has("scout"):
			enemy.position = Vector2(800,630)
			shown.scout = true
		elif enemy.enemy_kind == "goblin-brute" and not shown.has("brute"):
			enemy.position = Vector2(900,780)
			shown.brute = true
		else:
			enemy.position = Vector2(2300,1500)
	hero.summon_skeleton()
	for companion in get_nodes_in_group("companions"):
		companion.set_physics_process(false)
	await frames(55)
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://artifacts/creatures")
	root.get_texture().get_image().save_png("res://artifacts/creatures/party.png")
	for companion in get_nodes_in_group("companions"):
		companion.set_physics_process(true)
	hero.dismiss_companions()
	await frames(40)
	for enemy in get_nodes_in_group("enemies"):
		enemy.position = Vector2(2300,1500)
	var contact := Image.create(192*6,192*2,false,Image.FORMAT_RGBA8)
	for row in 2:
		hero.position = Vector2(600,640)
		hero.casting_remaining = 0
		var action := "move_right" if row == 0 else "move_up"
		Input.action_press(action)
		for frame in 6:
			await frames(5)
			await RenderingServer.frame_post_draw
			var screen: Vector2 = hero.get_global_transform_with_canvas().origin
			var region := Rect2i(Vector2i(screen)-Vector2i(96,132),Vector2i(192,192))
			var pose := root.get_texture().get_image().get_region(region)
			contact.blit_rect(pose,Rect2i(0,0,192,192),Vector2i(frame*192,row*192))
		Input.action_release(action)
	contact.save_png("res://artifacts/creatures/walk-gameplay.png")
	print("Saved real party and front/back walk gameplay captures")
	quit()
