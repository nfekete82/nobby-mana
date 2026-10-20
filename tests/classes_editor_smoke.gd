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

func settle() -> void:
	await process_frame
	await process_frame
	await frames(6)

func run() -> void:
	preload("res://tests/test_support.gd").isolate_exploration(root)
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	check(not session.choose("invalid") and not session.choose("mage") and not session.choose("shaman"),"Removed/invalid classes are rejected")
	var menu = load("res://scenes/start.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(2)
	check(menu.choice_buttons.size() == 2 and menu.choice_buttons.has("monkey") and menu.choice_buttons.has("panda"),"Exactly the two personal animal heroes are selectable")
	menu.choice_buttons["panda"].pressed.emit()
	await settle()
	var world = current_scene
	var hero = world.hero
	check(hero.character_class == "panda" and hero.asset_id == "panda","Panda button starts actual panda gameplay")
	check(hero.health == 125 and hero.attack_damage == 28,"Panda has melee stats and starter wooden sword")
	check(world.summon_button.disabled and world.shoot_button.visible and world.mana_bar.visible and world.heal_button != null,"Panda reference HUD offers attack/healing and disables skeleton summoning")
	check(not hero.summon_skeleton() and hero.mana == 100,"Panda cannot summon or spend summon mana")
	hero.set_physics_process(false)
	var enemies := get_nodes_in_group("enemies")
	for foe in enemies:
		foe.set_physics_process(false)
	var enemy = enemies[0]
	hero.position = Vector2(600,640)
	enemy.position = Vector2(670,640)
	await frames(2)
	check(not hero.shoot_at(enemy.position) and get_nodes_in_group("projectiles").is_empty(),"Panda never spawns an arrow")
	check(hero.primary_action(enemy.position),"Panda primary action swings the actual sword")
	check(not hero.primary_action(enemy.position),"Melee recovery blocks duplicate attacks")
	check(enemy.health == 100,"Sword damage waits for swing windup")
	hero.set_physics_process(true)
	await frames(24)
	hero.set_physics_process(false)
	check(enemy.health == 72,"Wooden sword lands once for 28 damage")
	await frames(8)
	hero.attack_remaining = 0
	hero.position = Vector2(600,640)
	enemy.position = Vector2(670,640)
	enemy.invulnerable_remaining = 0
	world.add_wall(Vector2(635,640),Vector2(12,96))
	await frames(2)
	hero.primary_action(enemy.position)
	hero.set_physics_process(true)
	await frames(30)
	hero.set_physics_process(false)
	check(enemy.health == 72,"Solid world geometry blocks panda melee")
	var back := InputEventAction.new()
	back.action = "menu"
	back.pressed = true
	world._unhandled_input(back)
	await settle()
	menu = current_scene
	menu.choice_buttons["monkey"].pressed.emit()
	await settle()
	world = current_scene
	hero = world.hero
	check(hero.asset_id == "monkey-shaman" and hero.is_summoner(),"Monkey retains its summon class")
	check(hero.sprite.sprite_frames.get_frame_count("walk_back") == 6,"Monkey has six separate rear walking poses")
	hero.set_physics_process(false)
	enemies = get_nodes_in_group("enemies")
	for foe in enemies:
		foe.set_physics_process(false)
	enemy = enemies[0]
	hero.position = Vector2(600,640)
	enemy.position = Vector2(850,640)
	await frames(2)
	check(hero.primary_action(enemy.position),"Monkey throws arrow with the same primary input")
	check(hero.mana == 100,"Basic arrow costs no mana")
	await frames(32)
	check(enemy.health == 82,"Thrown arrow deals 18 damage")
	hero.shot_cooldown = 0
	world.add_wall(Vector2(710,640),Vector2(20,128))
	await frames(2)
	hero.shoot_at(enemy.position)
	await frames(32)
	check(enemy.health == 82,"Walls still block monkey projectiles")
	hero.shot_cooldown = 0
	hero.shoot_at(Vector2(600,1600))
	await frames(65)
	check(get_nodes_in_group("projectiles").is_empty(),"Missed arrows expire at maximum range")
	check(hero.summon_skeleton() and hero.companion_count() == 1,"Monkey still summons a real companion")
	check(world.world_pixels() == Vector2(3584,5120),"World is 56 by 80 native tiles")
	check(world.navigation().grid.region.size == Vector2i(112,160),"Navigation covers both old world and new district")
	check(world.level.has_node("Scenery/RiverCottage"),"Native village houses exist in actual world")
	check(not world.navigation().free_at(Vector2(2624,930)),"House ground footprint blocks movement")
	check(world.navigation().free_at(Vector2(2624,770)),"House roof does not block walking behind it")
	# The temporary wall above deliberately blocks one straight approach, but
	# pathfinding must route around it and through the original boundary trees.
	check(not world.navigation().path(Vector2(448,640),Vector2(2920,1088)).is_empty(),"Village is reachable from original spawn")
	check(not world.navigation().path(Vector2(2100,1100),Vector2(2144,2190)).is_empty(),"Southern clearing is reachable through existing trees")
	var camera: Camera2D
	for child in hero.get_children():
		if child is Camera2D:
			camera = child
	check(camera.limit_right == 3584 and camera.limit_bottom == 5120,"Camera follows expanded bounds")
	var ground: TileMapLayer = world.level.get_node("Ground")
	var barriers: TileMapLayer = world.level.get_node("Barriers")
	ground.erase_cell(Vector2i(2,20))
	barriers.set_cell(Vector2i(10,10),0,Vector2i.ZERO)
	world.level.get_node("Encounters").get_child(0).position = Vector2(900,600)
	await frames(3)
	world._navigation = null
	check(not world.navigation().free_at(Vector2(672,672)),"Painted barrier blocks physics while visually hidden")
	var packed := PackedScene.new()
	check(packed.pack(world.level) == OK,"Base editor scene can still be packed")
	var temporary := "user://editor-roundtrip-test.tscn"
	check(ResourceSaver.save(packed,temporary) == OK,"Edited level saves to temporary file")
	var restored = ResourceLoader.load(temporary,"",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	check(restored.get_node("Ground").get_cell_source_id(Vector2i(2,20)) == -1,"Painted terrain survives save/reload")
	check(restored.get_node("Barriers").get_used_cells().has(Vector2i(10,10)),"Painted collision survives save/reload")
	check(restored.get_node("Encounters").get_child(0).position == Vector2(900,600),"Moved encounter survives save/reload")
	check(not restored.has_node("WoodlandVillage"),"Generated district instance does not duplicate into base scene save")
	restored.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary))
	# Actual class transition must clean up existing party and projectiles.
	hero.shot_cooldown = 0
	hero.hurt_remaining = 0
	hero.shoot_at(Vector2(600,1600))
	world._unhandled_input(back)
	await settle()
	check(get_nodes_in_group("projectiles").is_empty() and get_nodes_in_group("companions").is_empty(),"Hero switch removes arrows and previous party")
	print("Duo/projectile/village/editor smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	quit(0 if failures.is_empty() else 1)
