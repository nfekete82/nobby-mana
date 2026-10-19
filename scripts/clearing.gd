extends Node2D

const Art = preload("res://scripts/art_library.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const ResourceOrb = preload("res://scripts/resource_orb.gd")
const Navigation = preload("res://scripts/navigation.gd")
const WORLD_SIZE := Vector2i(24, 18)
const TILE := 64
var hero: CharacterBody2D
var actors: Node2D
var health_bar: Range
var status: Label
var mana_bar: Range
var party_label: Label
var summon_message: Label
var summon_button: Button
var hud_dock: Control
var message_timer: Timer
var _navigation: RefCounted
var remaining := 2

func _ready() -> void:
	configure_input()
	if not ResourceLoader.exists("res://assets/licensed/hero-stand.png"):
		var message := Label.new()
		message.text = "Grafiken fehlen. Bitte zuerst python3 tools/setup_assets.py ausführen."
		message.position = Vector2(32, 64)
		add_child(message)
		push_error(message.text)
		return
	build_ground()
	actors = Node2D.new()
	actors.name = "Actors"
	actors.y_sort_enabled = true
	add_child(actors)
	build_forest()
	hero = Player.new()
	hero.name = "Nobby"
	hero.position = Vector2(448, 640)
	actors.add_child(hero)
	hero.health_changed.connect(func(current: int, _maximum: int): health_bar.value = current)
	hero.defeated.connect(func(): status.text = "Nobby ist erschöpft. Drücke F5 für einen neuen Versuch.")
	for point in [Vector2(850, 570), Vector2(1050, 770)]:
		var enemy := Enemy.new()
		enemy.position = point
		actors.add_child(enemy)
		enemy.defeated.connect(on_enemy_defeated)
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
		"attack": [KEY_SPACE, KEY_J], "summon": [KEY_R], "restart": [KEY_F5],
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key: int in bindings[action]:
				var event := InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func tile(texture: Texture2D, cell: Vector2i, atlas: Vector2i) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = Rect2(atlas * TILE, Vector2i(TILE, TILE))
	sprite.position = Vector2(cell * TILE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

func build_ground() -> void:
	var grass: Texture2D = load("res://assets/licensed/grass.png")
	var path: Texture2D = load("res://assets/licensed/path.png")
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			tile(grass, Vector2i(x,y), Vector2i(1,1))
	# One connected rectangular clearing with original edge and corner cells.
	for y in range(6, 14):
		for x in range(4, 20):
			var atlas := Vector2i(0 if x == 4 else (2 if x == 19 else 1), 0 if y == 6 else (2 if y == 13 else 1))
			tile(path, Vector2i(x,y), atlas)
	add_wall(Vector2(768, -16), Vector2(1536,32))
	add_wall(Vector2(768,1168),Vector2(1536,32))
	add_wall(Vector2(-16,576),Vector2(32,1152))
	add_wall(Vector2(1552,576),Vector2(32,1152))

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

func prop(id: String, at: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = at
	body.collision_layer = 1 if id != "bush" else 0
	body.collision_mask = 0
	body.add_child(Art.sprite_for(id))
	if id != "bush":
		var shape := RectangleShape2D.new()
		var data: Dictionary = Art.registry().assets[id]
		shape.size = Vector2(data.hitbox[0], data.hitbox[1])
		var collider := CollisionShape2D.new()
		collider.shape = shape
		collider.position.y = -shape.size.y / 2
		body.add_child(collider)
	actors.add_child(body)

func build_forest() -> void:
	for x in range(1, 24, 2):
		prop("tree-oak",Vector2(x * TILE, 290 + (x % 3) * 16))
		prop("tree-small",Vector2(x * TILE + 32, 1110))
	for y in range(5,16,2):
		prop("tree-oak",Vector2(100,y * TILE))
		prop("tree-small",Vector2(1460,y * TILE))
	for point in [Vector2(250,480),Vector2(1200,400),Vector2(310,960),Vector2(1260,910),Vector2(600,350)]:
		prop("bush",point)

func build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var screen := Control.new()
	screen.name = "Screen"
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_dock = Control.new()
	hud_dock.name = "ResourceDock"
	hud_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(hud_dock)
	hud_dock.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hud_dock.offset_left = -160
	hud_dock.offset_right = 160
	hud_dock.offset_top = -94
	hud_dock.offset_bottom = -10
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(48,22)
	panel.size = Vector2(224,50)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("192830")
	background.border_color = Color("796443")
	background.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel",background)
	hud_dock.add_child(panel)
	health_bar = ResourceOrb.new()
	health_bar.name = "HealthOrb"
	health_bar.position = Vector2(0,12)
	health_bar.size = Vector2(64,64)
	health_bar.max_value = hero.max_health
	health_bar.value = hero.health
	hud_dock.add_child(health_bar)
	mana_bar = ResourceOrb.new()
	mana_bar.name = "ManaOrb"
	mana_bar.mana_style = true
	mana_bar.position = Vector2(256,12)
	mana_bar.size = Vector2(64,64)
	mana_bar.max_value = hero.MAX_MANA
	mana_bar.step = 0
	hud_dock.add_child(mana_bar)
	summon_button = Button.new()
	summon_button.name = "Summon"
	summon_button.text = "R · Erwecken"
	summon_button.position = Vector2(93,27)
	summon_button.size = Vector2(134,23)
	summon_button.add_theme_font_size_override("font_size",13)
	summon_button.focus_mode = Control.FOCUS_NONE
	summon_button.tooltip_text = "Skelett erwecken · 10 Mana · bis zu 3 Begleiter für 2 Minuten.\nWASD/Pfeile: bewegen · Leertaste/J: Angriff · F5: Neustart"
	summon_button.pressed.connect(func(): hero.summon_skeleton())
	hud_dock.add_child(summon_button)
	party_label = Label.new()
	party_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	party_label.position = Vector2(70,51)
	party_label.size = Vector2(180,18)
	party_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	party_label.add_theme_font_size_override("font_size",11)
	party_label.add_theme_color_override("font_color",Color("eee2c3"))
	hud_dock.add_child(party_label)
	for data in [["LEBEN",0],["MANA",256]]:
		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.text = data[0]
		label.position = Vector2(data[1],-2)
		label.size = Vector2(64,14)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",10)
		label.add_theme_color_override("font_color",Color("eee2c3"))
		label.add_theme_color_override("font_outline_color",Color("16242d"))
		label.add_theme_constant_override("outline_size",3)
		hud_dock.add_child(label)
	status = Label.new()
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(status)
	status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	status.offset_left = -300
	status.offset_right = 300
	status.offset_top = 12
	status.offset_bottom = 36
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.text = "Waldlichtung · 2 Wächter"
	status.add_theme_font_size_override("font_size",13)
	status.add_theme_color_override("font_color",Color("eee2c3"))
	status.add_theme_color_override("font_outline_color",Color("16242d"))
	status.add_theme_constant_override("outline_size",4)
	summon_message = Label.new()
	summon_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(summon_message)
	summon_message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	summon_message.offset_left = -300
	summon_message.offset_right = 300
	summon_message.offset_top = -124
	summon_message.offset_bottom = -100
	summon_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summon_message.add_theme_font_size_override("font_size",12)
	summon_message.add_theme_color_override("font_outline_color",Color("16242d"))
	summon_message.add_theme_constant_override("outline_size",4)
	summon_message.hide()
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 2.5
	message_timer.timeout.connect(summon_message.hide)
	layer.add_child(message_timer)

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
	var count: int = hero.companion_count()
	mana_bar.value = hero.mana
	party_label.text = "Skelette %d / 3 · 10 Mana" % count
	summon_button.disabled = hero.dead or hero.mana < hero.SUMMON_COST or count >= hero.SUMMON_LIMIT

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
