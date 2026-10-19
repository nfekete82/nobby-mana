extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for frame in 3:
		await physics_frame
	var party := "--companions" in OS.get_cmdline_user_args()
	var combat := "--combat" in OS.get_cmdline_user_args()
	if combat:
		scene.hero.position = Vector2(650,640)
	if party or combat:
		for count in 3:
			scene.hero.summon_skeleton()
	for frame in (90 if combat else (50 if party else 12)):
		await physics_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var name := "summon-combat" if combat else ("summon-party" if party else "clearing")
	var error := root.get_texture().get_image().save_png("res://artifacts/" + name + ".png")
	print("Screenshot ", name, ": ", error)
	quit(error)
