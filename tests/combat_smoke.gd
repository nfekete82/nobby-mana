extends SceneTree
## Real physics checks: normalized movement, walls, attack timing, damage, death.

const Scene = preload("res://scenes/clearing.tscn")
var errors: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	preload("res://tests/test_support.gd").isolate_exploration(root)
	var world := Scene.instantiate()
	root.add_child(world)
	await physics_frame
	await physics_frame
	var initial_enemies: int = world.remaining
	var hero = world.hero
	check(hero != null, "Player spawns")
	if hero == null:
		quit(1)
		return
	# Disable autonomous enemies to make combat assertions deterministic.
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	var enemy = get_nodes_in_group("enemies")[0]
	var second = get_nodes_in_group("enemies")[1]
	var start: Vector2 = hero.position
	Input.action_press("move_right")
	for frame in 30:
		await physics_frame
	Input.action_release("move_right")
	var straight: float = hero.position.distance_to(start)
	hero.position = start
	Input.action_press("move_right")
	Input.action_press("move_down")
	for frame in 30:
		await physics_frame
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(absf(hero.position.distance_to(start) - straight) < 5, "Diagonal speed stays normalized")
	hero.position = Vector2(20,640)
	Input.action_press("move_left")
	for frame in 30:
		await physics_frame
	Input.action_release("move_left")
	check(hero.position.x >= 15, "World wall blocks movement")
	hero.position = Vector2(600,640)
	hero.facing = Vector2.RIGHT
	enemy.position = Vector2(670,640)
	check(not hero.can_hit(Vector2(530,640)), "Attack excludes targets behind the hero")
	check(not hero.can_hit(Vector2(800,640)), "Attack excludes distant targets")
	hero.start_attack()
	check(enemy.health == 100, "Attack has a windup")
	for frame in 30:
		await physics_frame
	check(enemy.health == 75, "One swing deals exactly one hit")
	enemy.take_damage(25,hero.position)
	check(enemy.health == 75, "Damage immunity prevents duplicate hits")
	enemy.invulnerable_remaining = 0
	enemy.take_damage(100,hero.position)
	check(enemy.dead and enemy.health == 0, "Lethal damage defeats enemy")
	check(world.remaining == initial_enemies-1, "Defeat updates objective once")
	enemy.take_damage(100,hero.position)
	check(world.remaining == initial_enemies-1, "Repeated damage cannot duplicate defeat")
	# A solid obstacle between close actors must stop melee.
	second.position = Vector2(670,640)
	world.add_wall(Vector2(635,628),Vector2(12,64))
	await physics_frame
	await physics_frame
	hero.resolve_attack()
	check(second.health == 100, "World wall blocks melee")
	hero.take_damage(100,second.position)
	check(hero.dead, "Hero can be defeated")
	print("Combat smoke: ", "PASS" if errors.is_empty() else "FAIL", " (", errors.size(), " failures)")
	world.queue_free()
	quit(0 if errors.is_empty() else 1)
