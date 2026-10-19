extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var options := OS.get_cmdline_user_args()
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	session.selected_class = "panda" if "--panda" in options else "monkey"
	var menu := "--menu" in options
	var party := "--companions" in options
	var combat := "--combat" in options
	var east := "--east" in options
	var scene = load("res://scenes/start.tscn" if menu else "res://scenes/clearing.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for frame in 3:
		await physics_frame
	if east:
		scene.hero.position = Vector2(2000,900)
	elif combat:
		scene.hero.position = Vector2(650,640)
	if party or combat:
		for count in 3:
			scene.hero.summon_skeleton()
	if "--shoot" in options:
		scene.hero.position = Vector2(600,640)
		var enemy = get_nodes_in_group("enemies")[0]
		enemy.position = Vector2(900,640)
		enemy.set_physics_process(false)
		await physics_frame
		scene.hero.primary_action(enemy.position)
	for frame in (90 if combat else (50 if party else 12)):
		await physics_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var name := "clearing"
	if menu:
		name = "class-selection"
	elif east:
		name = "eastern-glade"
	elif "--shoot" in options:
		name = "panda-melee" if "--panda" in options else "monkey-shot"
	elif combat:
		name = "summon-combat"
	elif party:
		name = "summon-party"
	var error := root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
	print("Screenshot ",name,": ",error)
	quit(error)
