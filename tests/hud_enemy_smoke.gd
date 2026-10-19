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
	preload("res://tests/test_support.gd").isolate_exploration(root)
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
	check(world.health_bar.value == 75, "LP bar reads actual player health")
	check(world.health_numbers.text == "75/100", "LP numbers reflect actual health")
	world.hero.mana = 40
	world.hero.mana_changed.emit(40,100)
	check(world.mana_bar.value == 40, "MP bar reads actual player mana")
	check(world.mana_numbers.text == "40/100", "MP numbers reflect actual mana")
	check(not world.heal_button.disabled and world.hero.heal_self(), "Heal button is enabled when hurt with enough mana")
	check(world.hero.health == 100 and world.hero.mana == 20, "Healing restores up to 35 LP and costs 20 MP")
	check(not world.hero.heal_self() and world.hero.mana == 20, "Full health refuses healing without cost")
	world.hero.health = 40
	world.hero.mana = 19
	check(not world.hero.heal_self(), "Insufficient MP blocks healing")
	check(world.item_button.disabled, "Item slot truthfully disabled without inventory")
	for dimensions in [Vector2i(960,640),Vector2i(1280,720),Vector2i(640,480)]:
		root.size = dimensions
		await process_frame
		await process_frame
		var rect: Rect2 = world.hud_dock.get_global_rect()
		var visible: Rect2 = root.get_visible_rect()
		check(absf(rect.position.x-12) < 1, "HUD stays anchored left at %s" % dimensions)
		check(absf(rect.end.y-(visible.size.y-10)) < 1, "HUD stays ten pixels from bottom at %s" % dimensions)
		check(rect.size == Vector2(312,126), "HUD remains compact at %s" % dimensions)
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
