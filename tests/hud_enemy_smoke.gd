extends SceneTree
const Scene = preload("res://scenes/clearing.tscn")
var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := Scene.instantiate()
	root.add_child(world)
	current_scene = world
	await physics_frame
	await physics_frame
	var initial_enemies: int = world.remaining
	world.hero.set_physics_process(false)
	var enemies := get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
	var enemy = enemies[0]
	check(enemy.health_bar.size == Vector2(48,6), "Enemy bar stays slim despite theme minimums")
	check(enemy.health_bar.value == 100, "Enemy bar starts full")
	check(enemy.health_bar.position.y < -90, "Enemy bar sits above the head")
	enemy.take_damage(25,world.hero.position)
	check(enemy.health_bar.value == 75, "Enemy bar responds to damage")
	var before: Vector2 = enemy.health_bar.global_position
	enemy.position += Vector2(40,20)
	check(enemy.health_bar.global_position == before + Vector2(40,20), "Enemy bar follows its actor")
	world.hero.take_damage(25,enemy.position)
	check(world.health_bar.value == 75, "Health orb reads actual player health")
	check(world.health_bar.fill_material.get_shader_parameter("amount") == 0.75, "Health fill reflects resource ratio")
	world.hero.mana = 40
	world.hero.mana_changed.emit(40,100)
	check(world.mana_bar.value == 40, "Mana orb reads actual player mana")
	check(is_equal_approx(world.mana_bar.fill_material.get_shader_parameter("amount"),0.4), "Mana fill reflects resource ratio")
	for dimensions in [Vector2i(960,640),Vector2i(1280,720),Vector2i(640,480)]:
		root.size = dimensions
		await process_frame
		await process_frame
		var rect: Rect2 = world.hud_dock.get_global_rect()
		var visible: Rect2 = root.get_visible_rect()
		check(absf(rect.position.x-12) < 1, "HUD stays anchored left at %s" % dimensions)
		check(absf(rect.end.y-(visible.size.y-10)) < 1, "HUD stays ten pixels from bottom at %s" % dimensions)
		check(rect.size == Vector2(432,180), "HUD remains compact at %s" % dimensions)
	enemy.invulnerable_remaining = 0
	enemy.take_damage(100,world.hero.position)
	check(not enemy.health_bar.visible, "Dead enemy hides health bar immediately")
	check(not enemy.is_in_group("enemies"), "Dead enemy leaves targeting group immediately")
	check(world.remaining == initial_enemies-1, "Defeat advances objective exactly once")
	enemy.take_damage(100,world.hero.position)
	check(world.remaining == initial_enemies-1, "Repeated damage cannot count defeat twice")
	await create_timer(0.45).timeout
	check(not is_instance_valid(enemy), "Dead enemy is removed from the scene after fade")
	check(get_nodes_in_group("enemies").size() == initial_enemies-1, "Living enemy remains after cleanup")
	print("HUD/enemy smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	world.queue_free()
	quit(0 if failures.is_empty() else 1)
