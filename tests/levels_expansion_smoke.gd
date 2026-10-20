extends SceneTree
const Progression = preload("res://scripts/progression.gd")
const Exploration = preload("res://scripts/exploration.gd")
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
func freeze(world: Node2D) -> void:
	world.hero.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
func run() -> void:
	var session := preload("res://tests/test_support.gd").isolate_exploration(root)
	var file := "user://levels-smoke-%d.json" % OS.get_process_id()
	session.progression = Progression.new(file)
	var old_map := "res://scenes/levels/reference_grove.tscn|56x40"
	session.exploration.ensure_map(old_map,Vector2i(56,40))
	session.exploration.reveal(old_map,Vector2i(40,20),2)
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	freeze(world)
	var hero = world.hero
	check(world.world_pixels() == Vector2(3584,5120),"Height and surface area doubled")
	check(world.remaining == 28,"28 authored opponents replace six encounters")
	check(root.content_scale_size == Vector2i(1152,800),"Larger native viewport gives wider and taller camera view")
	check(world.minimap.map_view.size == Vector2(84,120),"Whole taller map fits small panel without distortion")
	check(session.exploration.is_explored(world.minimap.map_id,Vector2i(40,20)),"Existing exploration migrates from original map")
	check(not session.exploration.is_explored(world.minimap.map_id,Vector2i(40,60)),"New southern area remains unexplored")
	var nav = world.navigation()
	for enemy in get_nodes_in_group("enemies"):
		if enemy.name.is_empty():
			continue
		check(nav.free_at(enemy.position),"Free enemy feet at %s" % enemy.position)
		check(not nav.path(hero.position,enemy.position).is_empty(),"Enemy reachable at %s" % enemy.position)
		check(hero.position.distance_to(enemy.position) > 290,"No enemy attacks immediately on spawn")
	for point in [Vector2(1312,4648),Vector2(2656,4648),Vector2(1728,3840)]:
		check(not nav.path(hero.position,point).is_empty(),"South/second crossing reachable at %s" % point)
	check(not nav.free_at(Vector2(1728,3400)),"Southern river blocks walking away from bridge")
	check(nav.free_at(Vector2(1728,3840)),"Second bridge really opens river collision")
	# Physically walk the added deck, rather than relying on path metadata.
	hero.position = Vector2(1480,3840)
	hero.set_physics_process(true)
	Input.action_press("move_right")
	await frames(145)
	Input.action_release("move_right")
	hero.set_physics_process(false)
	check(hero.position.x > 1950,"Hero crosses the actual second bridge")
	# Kill through a real companion swing; repeat damage must never duplicate EP.
	hero.position = Vector2(1240,1120)
	check(hero.summon_skeleton(),"Summon remains available before XP test")
	var companion = get_nodes_in_group("companions")[0]
	companion.set_physics_process(false)
	companion.position = Vector2(1250,1120)
	companion.facing = Vector2.RIGHT
	var enemy = get_nodes_in_group("enemies")[0]
	enemy.position = Vector2(1320,1120)
	enemy.health = 10
	enemy.invulnerable_remaining = 0
	await frames(3)
	companion.resolve_attack()
	check(enemy.dead and hero.experience == 35,"Skeleton kill grants correct owner experience")
	enemy.take_damage(100,hero.position)
	check(hero.experience == 35 and world.experience_bar.value == 35,"Duplicate damage grants no extra EP, HUD uses actual value")
	hero.health = 20
	hero.mana = 20
	hero.gain_experience(65)
	check(hero.level == 2 and hero.experience == 0 and hero.experience_required == 150,"Exact EP threshold reaches level 2")
	check(hero.max_health == 112 and hero.health == 112 and hero.max_mana == 105 and hero.mana == 105,"Level restores and increases both resources")
	check(hero.attack_damage == 28 and hero.ranged_damage == 21,"Monkey melee and arrow damage scale")
	check(world.health_bar.max_value == 112 and world.mana_bar.max_value == 105,"HUD maxima track level stats")
	check(world.party_label.text.contains("Lv.2") and world.summon_message.text.contains("Level 2"),"Level is visible and level-up feedback appears")
	# Use the actual projectile action and impact after leveling.
	var victim = get_nodes_in_group("enemies")[0]
	hero.position = Vector2(600,640)
	victim.position = Vector2(850,640)
	victim.invulnerable_remaining = 0
	var hp: int = victim.health
	hero.shot_cooldown = 0
	hero.casting_remaining = 0
	check(hero.shoot_at(victim.position),"Leveled monkey can throw")
	await frames(32)
	check(victim.health == hp-21,"Actual arrow impact uses improved damage")
	hero.gain_experience(350)
	check(hero.level == 4 and hero.experience == 0,"One reward can cross multiple levels correctly")
	hero.gain_experience(-25)
	check(hero.level == 4,"Invalid negative rewards are ignored")
	world.queue_free()
	await frames(3)
	# Fresh disk-backed store and actual class changes preserve separate heroes.
	session.progression = Progression.new(file)
	session.choose("panda")
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(3)
	freeze(world)
	check(world.hero.level == 1 and world.hero.max_health == 125,"Panda starts with its own progress and base stats")
	world.hero.gain_experience(100)
	check(world.hero.level == 2 and world.hero.attack_damage == 32 and world.hero.max_health == 140,"Panda level improves wooden sword and melee health")
	world.queue_free()
	await frames(3)
	session.progression = Progression.new(file)
	session.choose("monkey")
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(3)
	freeze(world)
	check(world.hero.level == 4 and world.hero.max_health == 136,"Monkey level survives disk reload and class switch")
	world.hero.take_damage(10000,Vector2.ZERO)
	world.hero.gain_experience(100)
	check(session.progression.stats("monkey").total == 450,"Defeated hero cannot receive posthumous rewards")
	world.queue_free()
	await frames(3)
	var writer := FileAccess.open(file,FileAccess.WRITE)
	writer.store_string("bad json")
	writer.close()
	var invalid := Progression.new(file)
	check(invalid.stats("monkey").level == 1,"Malformed save safely starts at level one")
	invalid.award("monkey",1000000)
	check(invalid.stats("monkey").level == 50,"Maximum level bounds oversized rewards")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(file+".tmp"))
	session.progression = Progression.new("")
	print("Levels/expanded-world/persistence smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	quit(0 if failures.is_empty() else 1)
