extends SceneTree
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
func run() -> void:
	var session := preload("res://tests/test_support.gd").isolate_exploration(root)
	var test_path := "user://minimap-smoke-%d.json" % OS.get_process_id()
	var store := Exploration.new(test_path)
	session.exploration = store
	var world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(4)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	hero_freeze(world)
	var mini = world.minimap
	check(mini.base_image.get_size() == Vector2i(168,120),"Small map matches actual 56x40 territory")
	check(mini.fog_image.get_pixel(0,0) == Color.BLACK,"Unknown ground is fully black")
	var house := Vector2i(41,15)
	check(mini.fog_image.get_pixelv(house*3) == Color.BLACK,"Distant unknown house/location is hidden too")
	var start := Vector2i((world.hero.position/64).floor())
	check(store.is_explored(mini.map_id,start),"Starting area is revealed")
	check(mini.fog_image.get_pixelv(start*3) == mini.base_image.get_pixelv(start*3),"Revealed tile uses actual world artwork")
	var key: String = mini.map_id
	var count: int = store.maps[key].cells.size()
	var before_walk: Vector2 = world.hero.position
	world.hero.set_physics_process(true)
	Input.action_press("move_right")
	await frames(35)
	Input.action_release("move_right")
	world.hero.set_physics_process(false)
	mini.update_exploration()
	check(world.hero.position.x > before_walk.x+100 and store.maps[key].cells.size() > count,"Actual walking discovers new cells")
	world.hero.position = Vector2(2144,1120)
	mini.update_exploration()
	var next := Vector2i((world.hero.position/64).floor())
	check(store.is_explored(key,next) and store.is_explored(key,start),"Exploration grows without hiding previously visited ground")
	check(store.maps[key].cells.size() > count,"Moving into new territory adds explored cells")
	var expected: Vector2 = mini.map_view.position+Vector2(Vector2i((world.hero.position*3/64).round()))-Vector2(2,2)
	check(mini.player_marker.position == expected,"Location marker follows actual hero")
	check(mini.fog_image.get_pixel(0,0) == Color.BLACK,"Unvisited distant corner remains black after movement")
	# Opaque map panel must not trigger an attack in the world underneath.
	world.hero.shot_cooldown = 0
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = mini.get_global_rect().get_center()
	click.pressed = true
	root.push_input(click,true)
	await frames(2)
	check(world.hero.shot_cooldown == 0,"Clicking the minimap does not shoot through the overlay")
	click.pressed = false
	root.push_input(click,true)
	check(store.flush() == OK and FileAccess.file_exists(test_path),"Exploration saves to isolated local file")
	var restored := Exploration.new(test_path)
	restored.ensure_map(key,world.world_size)
	check(restored.is_explored(key,start) and restored.is_explored(key,next),"Exploration survives a fresh disk load")
	check(restored.reveal(key,Vector2i(-1,-1),6).is_empty(),"Out-of-bounds positions reveal nothing")
	check(not restored.is_explored(key,Vector2i(-1,1)),"Negative cells cannot alias saved indices")
	for dimensions in [Vector2i(960,640),Vector2i(1280,720),Vector2i(640,480)]:
		root.size = dimensions
		await process_frame
		await process_frame
		var rect: Rect2 = mini.get_global_rect()
		check(rect.size == Vector2(180,146),"Minimap remains small at %s"%dimensions)
		check(is_equal_approx(rect.end.x,root.get_visible_rect().size.x-12) and rect.position.y == 12,"Minimap stays top right at %s"%dimensions)
		check(not rect.intersects(world.hud_dock.get_global_rect()),"Small overlays do not overlap")
	world.queue_free()
	await frames(3)
	session.selected_class = "panda"
	world = load("res://scenes/clearing.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(3)
	check(world.minimap.store.is_explored(world.minimap.map_id,next),"Hero switch shares already explored territory")
	world.queue_free()
	await frames(3)
	# Invalid or stale local data must not break a playable map.
	var file := FileAccess.open(test_path,FileAccess.WRITE)
	file.store_string("broken json")
	file.close()
	var broken := Exploration.new(test_path)
	broken.ensure_map(key,Vector2i(56,40))
	check(not broken.is_explored(key,start),"Malformed save starts with clean fog without crashing")
	broken.ensure_map(key,Vector2i(2,2))
	check(broken.reveal(key,Vector2i.ZERO,6).size() == 4,"Reveal is clipped to actual map bounds")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path+".tmp"))
	session.exploration = Exploration.new("")
	print("Compact HUD/minimap/fog persistence smoke: ","PASS" if failures.is_empty() else "FAIL"," (",failures.size()," failures)")
	quit(0 if failures.is_empty() else 1)
func hero_freeze(world: Node2D) -> void:
	world.hero.set_physics_process(false)
