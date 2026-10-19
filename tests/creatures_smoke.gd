extends SceneTree
const Art = preload("res://scripts/art_library.gd")
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

func png(file: String) -> Image:
	var image := Image.new()
	check(image.load_png_from_buffer(FileAccess.get_file_as_bytes(file)) == OK,"Read sprite "+file)
	return image

func run() -> void:
	for id: String in ["monkey-shaman","goblin-scout","goblin-brute"]:
		var data: Dictionary = Art.registry().assets[id]
		check(Vector2i(int(data.frame[0]),int(data.frame[1])) == Vector2i(192,192) and Vector2i(int(data.foot[0]),int(data.foot[1])) == Vector2i(96,132),"Fixed native cells/feet for "+id)
		for state: String in data.animations:
			var animation: Dictionary = data.animations[state]
			var image := png("res://assets/compiled/"+str(animation.file))
			check(image.get_size() == Vector2i(int(animation.frames)*192,384),"Separate native cells and direction rows: "+id+"/"+state)
			var counts: Array[int] = []
			counts.resize(int(animation.frames)*2)
			counts.fill(0)
			var binary := true
			for y in image.get_height():
				for x in image.get_width():
					var alpha := image.get_pixel(x,y).a8
					if alpha != 0 and alpha != 255:
						binary = false
					if alpha == 255:
						counts[(y/192)*int(animation.frames)+x/192] += 1
			check(binary and counts.min() > 100,"Binary alpha and nonempty frames: "+id+"/"+state)
	var monkey := png("res://assets/compiled/monkey-shaman-walk.png")
	var native := png("res://assets/licensed/shaman-walk.png")
	var same_legs := true
	var phases: Array[String] = []
	for row in 2:
		for frame in 4:
			var signature := ""
			for y in range(110,140):
				for x in range(80,112):
					var at := Vector2i(frame*192+x,row*192+y)
					if monkey.get_pixelv(at) != native.get_pixelv(at):
						same_legs = false
					signature += str(monkey.get_pixelv(at).to_rgba32())
			if row == 0:
				phases.append(signature)
	check(same_legs,"All original robe/leg pixels preserved in all four front/back gait poses")
	check(phases[0] != phases[2] and phases[1] != phases[3],"Opposite foot contacts and passing phases remain distinct")
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	var menu = load("res://scenes/start.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(2)
	check(menu.choice_buttons.has("monkey"),"Monkey shaman has a real class selection button")
	menu.choice_buttons["monkey"].pressed.emit()
	await process_frame
	await process_frame
	await frames(4)
	var world = current_scene
	if world == null:
		check(false,"Class scene completes loading")
		quit(1)
		return
	var hero = world.hero
	check(hero.asset_id == "monkey-shaman" and hero.is_summoner(),"Selecting monkey starts the playable shaman")
	check(hero.sprite.sprite_frames.get_frame_count("walk") == 4 and hero.sprite.sprite_frames.get_animation_speed("walk") == 12,"Native four-frame 12 FPS walk")
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	check(hero.summon_skeleton() and hero.companion_count() == 1,"Monkey summons an actual fighting skeleton")
	check(hero.sprite.animation == "heal" and hero.sprite.sprite_frames.get_frame_count("heal") == 11,"Summoning plays all eleven native casting poses")
	for companion in get_nodes_in_group("companions"):
		companion.set_physics_process(false)
	await frames(78)
	Input.action_press("move_up")
	await frames(8)
	Input.action_release("move_up")
	check(hero.sprite.animation == "walk_back","Movement after casting transitions to native rear walk")
	hero.set_physics_process(false)
	hero.position = Vector2(600,640)
	var warrior = get_nodes_in_group("enemies")[0]
	warrior.position = Vector2(850,640)
	await frames(2)
	check(hero.shoot_at(warrior.position),"Monkey throws a real ranged arrow")
	await frames(32)
	check(warrior.health == 82,"Monkey arrow deals damage on impact")
	var scout: CharacterBody2D
	var brute: CharacterBody2D
	for enemy in get_nodes_in_group("enemies"):
		if enemy.enemy_kind == "goblin-scout":
			scout = enemy
		elif enemy.enemy_kind == "goblin-brute":
			brute = enemy
	check(scout != null and brute != null,"Both goblin types spawn in the actual forest")
	check(scout.max_health == 45 and brute.max_health == 75,"Scout and brute have distinct health")
	check(scout.move_speed > brute.move_speed and brute.attack_damage > scout.attack_damage,"Scout is quicker, brute hits harder")
	hero.position = Vector2(1700,720)
	hero.invulnerable_remaining = 0
	scout.position = Vector2(1760,720)
	scout.home = scout.position
	scout.attack_delay = 0
	scout.repath_remaining = 0
	var hp: int = hero.health
	scout.set_physics_process(true)
	await frames(25)
	scout.set_physics_process(false)
	check(hero.health == hp-10,"Goblin AI actually attacks and damages the hero")
	scout.invulnerable_remaining = 0
	var before: int = world.remaining
	scout.take_damage(100,hero.position)
	check(not scout.health_bar.visible and world.remaining == before-1,"Goblin defeat updates objective once and hides bar")
	check(scout.sprite.animation.begins_with("death"),"Goblin plays its pixel death sequence")
	await create_timer(0.95).timeout
	check(not is_instance_valid(scout),"Goblin is removed after its death sequence")
	var marker = load("res://scenes/encounters/goblin_brute.tscn").instantiate()
	root.add_child(marker)
	check(marker.get_meta("enemy_kind") == "goblin-brute","Editor encounter prefab carries its enemy type")
	marker.queue_free()
	print("Creatures smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	world.queue_free()
	quit(0 if failures.is_empty() else 1)
