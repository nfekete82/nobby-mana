extends Node2D

const Art = preload("res://scripts/art_library.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const AdventureHUD = preload("res://scripts/adventure_hud.gd")
const Navigation = preload("res://scripts/navigation.gd")
var world_size := Vector2i(40,28)
var level: Node2D
const TILE := 64
var hero: CharacterBody2D
var actors: Node2D
var health_bar: Range
var status: Label
var mana_bar: Range
var party_label: Label
var summon_message: Label
var summon_button: Button
var shoot_button: Button
var hud_dock: Control
var message_timer: Timer
var health_numbers: Label
var mana_numbers: Label
var heal_button: Button
var item_button: Button
var _navigation: RefCounted
var remaining := 2

func _ready() -> void:
	configure_input()
	if not ResourceLoader.exists("res://assets/compiled/monkey-shaman-stand.png") or not ResourceLoader.exists("res://assets/compiled/panda-stand.png"):
		var message := Label.new()
		message.text = "Grafiken fehlen. Bitte zuerst python3 tools/setup_assets.py ausführen."
		message.position = Vector2(32, 64)
		add_child(message)
		push_error(message.text)
		return
	y_sort_enabled = true
	level = load("res://scenes/levels/reference_grove.tscn").instantiate()
	add_child(level)
	world_size = level.map_tiles
	var size := world_pixels()
	add_wall(Vector2(size.x/2,-16),Vector2(size.x,32))
	add_wall(Vector2(size.x/2,size.y+16),Vector2(size.x,32))
	add_wall(Vector2(-16,size.y/2),Vector2(32,size.y))
	add_wall(Vector2(size.x+16,size.y/2),Vector2(32,size.y))
	actors = Node2D.new()
	actors.name = "Actors"
	actors.y_sort_enabled = true
	add_child(actors)

	hero = Player.new()
	hero.name = "Nobby"
	hero.position = level.get_node("PlayerSpawn").position
	actors.add_child(hero)
	hero.health_changed.connect(func(_current: int, _maximum: int): refresh_party())
	hero.defeated.connect(func(): status.text = "Dein Held ist erschöpft. Drücke F5 für einen neuen Versuch.")
	var encounter_sets: Array[Node] = [level.get_node("Encounters")]
	if level.include_goblin_camp:
		var camp: Node2D = load("res://scenes/encounters/forest_goblins.tscn").instantiate()
		level.add_child(camp)
		encounter_sets.append(camp)
	remaining = 0
	for encounters in encounter_sets:
		for marker in encounters.get_children():
			var enemy := Enemy.new()
			enemy.enemy_kind = marker.get_meta("enemy_kind","warrior")
			enemy.position = marker.position
			actors.add_child(enemy)
			enemy.defeated.connect(on_enemy_defeated)
			remaining += 1
		encounters.hide()
	build_hud()
	hero.mana_changed.connect(func(_current: float, _maximum: float): refresh_party())
	hero.companions_changed.connect(refresh_party)
	hero.summon_feedback.connect(show_summon_feedback)
	hero.defeated.connect(refresh_party)
	refresh_party()

func configure_input() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"attack": [KEY_SPACE], "shoot": [KEY_J], "menu": [KEY_ESCAPE], "summon": [KEY_R], "heal": [KEY_H], "restart": [KEY_F5],
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key: int in bindings[action]:
				var event := InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_file("res://scenes/start.tscn")
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hero.primary_action(hero.aim_position())
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func add_wall(at: Vector2, size: Vector2) -> void:
	_navigation = null
	var body := StaticBody2D.new()
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 0
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func build_hud() -> void:
	AdventureHUD.build(self)

func show_summon_feedback(message: String) -> void:
	summon_message.text = "Skelett erweckt" if message.begins_with("Skelett erweckt") else message
	summon_message.show()
	message_timer.start()

func on_enemy_defeated() -> void:
	remaining -= 1
	if remaining == 0:
		status.text = "Lichtung befreit! F5 startet eine neue Runde."
	else:
		status.text = "Noch ein Wächter."

func refresh_party() -> void:
	if health_bar == null:
		return
	var count: int = hero.companion_count()
	health_bar.value = hero.health
	mana_bar.value = hero.mana
	health_numbers.text = "%d/%d" % [hero.health,hero.max_health]
	mana_numbers.text = "%d/%d" % [int(hero.mana),int(hero.MAX_MANA)]
	party_label.text = ("Affe\nSkelette %d/3" % count) if hero.is_summoner() else "Panda\nHolzschwert"
	shoot_button.disabled = hero.dead
	heal_button.disabled = hero.dead or hero.health >= hero.max_health or hero.mana < 20
	summon_button.disabled = not hero.is_summoner() or hero.dead or hero.mana < hero.SUMMON_COST or count >= hero.SUMMON_LIMIT
	if not hero.is_summoner():
		summon_button.tooltip_text = "Nur der Affen-Schamane kann Skelette erwecken."

func navigation() -> RefCounted:
	if _navigation == null:
		_navigation = Navigation.new(self)
	return _navigation

func summon_position(origin: Vector2) -> Variant:
	var nav = navigation()
	for radius in [56,80,104]:
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.DOWN,Vector2.UP,Vector2(1,1).normalized(),Vector2(-1,1).normalized(),Vector2(1,-1).normalized(),Vector2(-1,-1).normalized()]:
			var point: Vector2 = origin + direction * radius
			if not nav.free_at(point) or not nav.clear_line(origin,point) or nav.path(origin,point).is_empty():
				continue
			var occupied := false
			for group in ["allies","enemies"]:
				for actor in get_tree().get_nodes_in_group(group):
					if not actor.dead and point.distance_to(actor.global_position) < 38:
						occupied = true
			if not occupied:
				return point
	return null

func world_pixels() -> Vector2:
	return Vector2(world_size*TILE)
