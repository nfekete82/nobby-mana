extends SceneTree
## Exercise the real summon input, AI, pathfinding, faction damage and lifecycle.
const Scene = preload("res://scenes/clearing.tscn")
var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for index in count:
		await physics_frame

func run() -> void:
	var world := Scene.instantiate()
	root.add_child(world)
	current_scene = world
	await frames(3)
	var hero = world.hero
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	Input.action_press("summon")
	await frames(2)
	Input.action_release("summon")
	check(hero.companion_count() == 1, "R input summons one skeleton")
	check(is_equal_approx(hero.mana,90), "Summoning consumes exactly ten mana")
	check(hero.summon_skeleton() and hero.summon_skeleton(), "Consecutive summons have no cooldown")
	check(hero.companion_count() == 3, "Three companions can coexist")
	check(not hero.summon_skeleton() and is_equal_approx(hero.mana,70), "Fourth summon is rejected without mana cost")
	var allies := get_nodes_in_group("companions")
	for ally in allies:
		check(ally.health == 85, "Companion starts with old level-one health")
		check(ally.sprite.sprite_frames.get_frame_count("walk_back") == 6, "Back-facing walk preserves all frames")
		check(world.navigation().free_at(ally.global_position), "Spawn position respects world collisions")
		for other in allies:
			if other != ally:
				check(ally.position.distance_to(other.position) >= 38, "Summons do not overlap each other")
	var skeleton = allies[0]
	for ally in allies:
		ally.set_physics_process(false)
	skeleton.dismiss()
	check(hero.companion_count() == 2, "Dismissing releases the slot immediately")
	hero.mana = 9
	check(not hero.summon_skeleton() and hero.mana == 9, "Insufficient mana creates no companion")
	hero.set_physics_process(false)
	hero.mana_idle_remaining = 0.25
	hero.regenerate_mana(0.25,false)
	check(hero.mana == 9, "Mana waits for idle grace")
	hero.regenerate_mana(1,false)
	check(hero.mana == 14, "Idle regeneration is five mana per second")
	hero.regenerate_mana(1,true)
	check(hero.mana == 14, "Actions prevent mana regeneration")
	hero.mana = 99
	hero.mana_idle_remaining = 0
	hero.regenerate_mana(1,false)
	check(hero.mana == 100, "Mana is capped at maximum")
	check(hero.summon_skeleton() and hero.companion_count() == 3, "A released slot can be summoned again")
	var free_slots: Array[int] = []
	for ally in get_nodes_in_group("companions"):
		check(ally.slot not in free_slots, "Formation slots remain unique")
		free_slots.append(ally.slot)
		ally.set_physics_process(false)
	# All further AI assertions use the two still living original summons.
	skeleton = allies[1]
	var enemy = get_nodes_in_group("enemies")[0]
	var second = get_nodes_in_group("enemies")[1]
	hero.position = Vector2(450,700)
	skeleton.position = Vector2(650,640)
	enemy.position = Vector2(710,640)
	second.position = Vector2(1400,800)
	skeleton.choose_route(world)
	check(skeleton.target == enemy, "Skeleton acquires a nearby reachable hostile")
	hero.position = Vector2(200,900)
	skeleton.choose_route(world)
	check(skeleton.target == enemy, "Combat focus stays when owner runs away")
	skeleton.facing = Vector2.RIGHT
	skeleton.start_attack()
	skeleton.set_physics_process(true)
	await frames(20)
	skeleton.set_physics_process(false)
	check(enemy.health == 90, "Autonomous skeleton attack actually damages enemy")
	check(hero.health == 100, "Companion attack cannot hurt owner")
	var ally_health: int = allies[2].health
	allies[2].position = skeleton.position + Vector2(25,0)
	skeleton.resolve_attack()
	check(allies[2].health == ally_health, "Companions cannot damage one another")
	allies[2].position = Vector2(300,600)
	# Enemies must fight the closest reachable ally, not only the hero.
	hero.position = Vector2(950,640)
	enemy.position = Vector2(710,640)
	enemy.home = enemy.position
	enemy.choose_target(world)
	check(enemy.target == skeleton, "Enemy selects the nearer skeleton")
	enemy.facing = enemy.position.direction_to(skeleton.position)
	skeleton.invulnerable_remaining = 0
	var hp: int = skeleton.health
	enemy.resolve_attack()
	check(skeleton.health == hp - 25, "Enemy melee damages skeleton")
	check(hero.health == 100, "Farther hero is protected from this melee")
	skeleton.invulnerable_remaining = 0
	enemy.attack_remaining = 0
	enemy.attack_delay = 0
	enemy.repath_remaining = 0
	hp = skeleton.health
	enemy.set_physics_process(true)
	await frames(20)
	enemy.set_physics_process(false)
	check(skeleton.health == hp - 25, "Enemy autonomous AI lands a timed hit on companion")
	check(hero.health == 100, "Autonomous enemy attack leaves distant owner unharmed")
	# Rejected spawn behind world geometry must not consume mana.
	hero.dismiss_companions()
	await frames(35)
	hero.position = Vector2(600,640)
	world.add_wall(hero.position,Vector2(260,260))
	var obstruction = world.get_child(world.get_child_count()-1)
	await frames(3)
	hero.mana = 100
	check(not hero.summon_skeleton(), "Blocked summon has no valid placement")
	check(hero.mana == 100 and hero.companion_count() == 0, "Blocked summon charges no mana")
	obstruction.queue_free()
	await frames(3)
	world._navigation = null
	check(hero.summon_skeleton(), "Summon succeeds after obstruction removed")
	skeleton = get_nodes_in_group("companions")[0]
	skeleton.set_physics_process(false)
	# A wall has a genuine route around it; enclosed targets have no route.
	skeleton.position = Vector2(600,640)
	enemy.position = Vector2(800,640)
	world.add_wall(Vector2(700,640),Vector2(24,220))
	var wall = world.get_child(world.get_child_count()-1)
	await frames(3)
	skeleton.choose_route(world)
	check(skeleton.target == enemy and skeleton.route.size() > 3, "Skeleton finds a route around wall")
	var detour := false
	for point in skeleton.route:
		if absf(point.y-640) > 100:
			detour = true
	check(detour, "Navigation waypoints go around the obstacle")
	skeleton.repath_remaining = 0
	enemy.invulnerable_remaining = 0
	var enemy_hp: int = enemy.health
	skeleton.set_physics_process(true)
	await frames(200)
	skeleton.set_physics_process(false)
	check(enemy.health < enemy_hp, "Skeleton actually walks around wall and lands a hit")
	# An enclosed nearby target must be rejected rather than using a partial path.
	skeleton.position = Vector2(600,640)
	enemy.position = Vector2(800,640)
	world.add_wall(enemy.position,Vector2(96,96))
	var enclosure = world.get_child(world.get_child_count()-1)
	await frames(3)
	skeleton.choose_route(world)
	check(skeleton.target == null, "Unreachable enclosed hostile is not acquired")
	enclosure.queue_free()
	await frames(3)
	world._navigation = null
	# Locking is bounded by distance as well as reachability.
	enemy.position = Vector2(1400,500)
	skeleton.choose_route(world)
	check(skeleton.target == null, "Target beyond leash is released")
	wall.queue_free()
	await frames(3)
	world._navigation = null
	# Verify actual following, with enemies outside acquisition range.
	hero.position = Vector2(850,900)
	skeleton.position = Vector2(500,850)
	var before: float = skeleton.position.distance_to(hero.position)
	skeleton.repath_remaining = 0
	skeleton.set_physics_process(true)
	await frames(50)
	skeleton.set_physics_process(false)
	check(skeleton.position.distance_to(hero.position) < before - 60, "Idle skeleton actually follows owner")
	skeleton.facing = Vector2.UP
	skeleton.animate_movement(Vector2.UP)
	check(skeleton.sprite.animation == "walk_back", "North movement uses the back row")
	skeleton.lifetime_remaining = 0.01
	skeleton.set_physics_process(true)
	await frames(3)
	check(hero.companion_count() == 0, "Two-minute lifetime releases slot")
	check(hero.summon_skeleton(), "Expired companion can be replaced")
	skeleton = get_nodes_in_group("companions")[0]
	skeleton.take_damage(100,enemy.position)
	check(hero.companion_count() == 0, "Killed companion releases slot immediately")
	check(hero.summon_skeleton(), "Killed companion can be replaced")
	hero.take_damage(100,enemy.position)
	check(hero.companion_count() == 0, "Owner death removes companions")
	check(not hero.summon_skeleton(), "Dead owner cannot summon")
	await frames(35)
	check(get_nodes_in_group("companions").is_empty(), "Cleanup leaves no active companions")
	var previous_id: int = world.get_instance_id()
	var restart := InputEventAction.new()
	restart.action = "restart"
	restart.pressed = true
	world._unhandled_input(restart)
	await frames(4)
	world = current_scene
	check(world.get_instance_id() != previous_id, "F5 reloads the current scene")
	check(world.hero.companion_count() == 0 and world.hero.mana == 100 and world.remaining == 2, "Restart resets party, mana and enemies")
	print("Companion smoke: ", "PASS" if failures.is_empty() else "FAIL", " (",failures.size()," failures)")
	world.queue_free()
	quit(0 if failures.is_empty() else 1)
