extends SceneTree
var failures: Array[String] = []

func check(condition: bool,message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for index in count:
		await physics_frame

func run() -> void:
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	check(not session.choose("invalid"),"Invalid class is rejected")
	var menu = load("res://scenes/start.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(2)
	menu.choice_buttons["mage"].pressed.emit()
	await frames(4)
	var world = current_scene
	var hero = world.hero
	check(hero.character_class == "mage" and hero.asset_id == "hero","Mage button starts actual mage gameplay")
	check(world.summon_button.disabled,"Mage HUD disables skeleton skill")
	check(not hero.summon_skeleton() and hero.mana == 100,"Mage cannot summon or spend summon mana")
	hero.set_physics_process(false)
	var enemies := get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
	var enemy = enemies[0]
	hero.position = Vector2(600,640)
	enemy.position = Vector2(850,640)
	await frames(2)
	check(hero.shoot_at(enemy.position),"Mage can launch projectile")
	check(enemy.health == 100,"Ranged damage waits for projectile travel")
	check(hero.mana == 94,"Arcane arrow consumes six mana")
	check(not hero.shoot_at(enemy.position),"Shot cooldown prevents duplicate cast")
	await frames(32)
	check(enemy.health == 75,"Arcane arrow hits once for 25 damage")
	check(get_nodes_in_group("projectiles").is_empty(),"Projectile is removed on impact")
	hero.shot_cooldown = 0
	world.add_wall(Vector2(710,640),Vector2(20,128))
	await frames(2)
	hero.shoot_at(enemy.position)
	await frames(32)
	check(enemy.health == 75,"World wall blocks arrows")
	hero.mana = 5
	hero.shot_cooldown = 0
	check(not hero.shoot_at(enemy.position) and hero.mana == 5,"Insufficient mana blocks arcane arrow without cost")
	hero.mana = 50
	hero.shot_cooldown = 0
	hero.shoot_at(Vector2(600,1600))
	check(get_nodes_in_group("projectiles").size() == 1,"Missed shot is alive while traveling")
	await frames(65)
	check(get_nodes_in_group("projectiles").is_empty(),"Missed shot expires at maximum range")
	hero.shot_cooldown = 0
	hero.shoot_at(Vector2(600,1600))
	check(get_nodes_in_group("projectiles").size() == 1,"Class switch begins with a live projectile")
	var back := InputEventAction.new()
	back.action = "menu"
	back.pressed = true
	world._unhandled_input(back)
	await frames(4)
	menu = current_scene
	check(menu.choice_buttons.has("shaman"),"Esc returns to class selection")
	check(get_nodes_in_group("projectiles").is_empty(),"Changing class cleans projectiles")
	menu.choice_buttons["shaman"].pressed.emit()
	await frames(4)
	world = current_scene
	hero = world.hero
	check(hero.character_class == "shaman" and hero.asset_id == "shaman","Shaman button starts native shaman hero")
	check(hero.sprite.sprite_frames.get_frame_count("walk_back") == 4,"Shaman preserves native four-pose back walk")
	check(hero.sprite.sprite_frames.get_animation_speed("walk") == 12,"Shaman walk uses native timing")
	hero.set_physics_process(false)
	enemies = get_nodes_in_group("enemies")
	for foe in enemies:
		foe.set_physics_process(false)
	enemy = enemies[0]
	hero.position = Vector2(600,640)
	enemy.position = Vector2(850,640)
	await frames(2)
	check(hero.shoot_at(enemy.position),"Shaman throws an arrow")
	check(hero.mana == 100,"Shaman basic arrow costs no mana")
	await frames(32)
	check(enemy.health == 82,"Thrown arrow deals 18 damage")
	enemy.invulnerable_remaining = 0
	hero.shot_cooldown = 0
	hero.set_physics_process(true)
	Input.action_press("shoot")
	await frames(2)
	Input.action_release("shoot")
	hero.set_physics_process(false)
	check(get_nodes_in_group("projectiles").size() == 1,"J action launches an actual projectile")
	await frames(32)
	check(enemy.health == 64,"J automatically aims at the nearest hostile")
	check(hero.summon_skeleton() and hero.companion_count() == 1,"Shaman retains summon skill")
	check(world.summon_button.get_child(0).texture is AtlasTexture,"Summon slot uses existing skeleton art")
	check(world.world_pixels() == Vector2(2560,1792),"Map is 40 by 28 native tiles")
	check(world.navigation().grid.region.size == Vector2i(80,56),"Navigation covers enlarged map")
	check(not world.navigation().path(Vector2(448,640),Vector2(2100,1100)).is_empty(),"Expanded eastern glade is reachable")
	var camera: Camera2D
	for child in hero.get_children():
		if child is Camera2D:
			camera = child
	check(camera.limit_right == 2560 and camera.limit_bottom == 1792,"Camera follows authored map bounds")
	var ground: TileMapLayer = world.level.get_node("Ground")
	var barriers: TileMapLayer = world.level.get_node("Barriers")
	ground.set_cell(Vector2i(2,20),0,Vector2i(2,1))
	barriers.set_cell(Vector2i(24,20),0,Vector2i(1,1))
	world.level.get_node("Encounters").get_child(0).position = Vector2(900,600)
	await frames(3)
	world._navigation = null
	check(not world.navigation().free_at(Vector2(1568,1312)),"Painted barrier blocks actual physics while visually hidden")
	var packed := PackedScene.new()
	check(packed.pack(world.level) == OK,"Authored level can be packed")
	var temporary := "user://editor-roundtrip-test.tscn"
	check(ResourceSaver.save(packed,temporary) == OK,"Edited level saves to a temporary test file")
	var restored = ResourceLoader.load(temporary,"",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	check(restored.get_node("Ground").get_cell_atlas_coords(Vector2i(2,20)) == Vector2i(2,1),"Painted terrain survives save and reload")
	check(restored.get_node("Barriers").get_used_cells().has(Vector2i(24,20)),"Painted collision survives save and reload")
	check(restored.get_node("Encounters").get_child(0).position == Vector2(900,600),"Moved encounter survives save and reload")
	restored.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary))
	print("Classes/projectile/editor smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	world.queue_free()
	quit(0 if failures.is_empty() else 1)
