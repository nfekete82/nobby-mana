extends SceneTree
var failures: Array[String] = []
func check(ok: bool,message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func run() -> void:
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	check(world.level.name == "ReferenceGrove","New reference-art world is the actual active level")
	check(world.level.get_node("Scenery").get_child_count() > 200,"Whole map has authored dense scenery")
	var nav = world.navigation()
	check(not nav.free_at(Vector2(1728,800)),"River blocks feet away from bridge")
	check(nav.free_at(Vector2(1728,1152)),"Bridge deck is actually walkable")
	check(not nav.path(Vector2(1240,1120),Vector2(2160,1120)).is_empty(),"Navigation crosses the authored bridge")
	check(not nav.clear_line(Vector2(1480,800),Vector2(1960,800)),"River banks block straight-line targeting")
	world.hero.position = Vector2(1480,1152)
	world.hero.casting_remaining = 0
	Input.action_press("move_right")
	await frames(145)
	Input.action_release("move_right")
	check(world.hero.position.x > 1950,"Hero really walks from west to east across the bridge")
	world.hero.position = Vector2(1500,850)
	Input.action_press("move_right")
	await frames(40)
	Input.action_release("move_right")
	check(world.hero.position.x < 1536,"Water collision stops actual movement beside crossing")
	world.hero.health = 40
	world.hero.mana = 100
	world.hero.hurt_remaining = 0
	Input.action_press("heal")
	await frames(2)
	Input.action_release("heal")
	check(world.hero.health == 75 and world.hero.mana == 80,"H key triggers actual heal with correct LP/MP")
	world.hero.dead = true
	check(not world.hero.heal_self(),"Defeated heroes cannot heal back to life")
	print("Reference grove/bridge/healing smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	world.queue_free()
	quit(0 if failures.is_empty() else 1)
