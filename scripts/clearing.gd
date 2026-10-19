extends Node2D

const Art = preload("res://scripts/art_library.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const ResourceOrb = preload("res://scripts/resource_orb.gd")
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
	y_sort_enabled = true
	level = load("res://scenes/levels/forest.tscn").instantiate()
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
	hero.health_changed.connect(func(current: int, _maximum: int): health_bar.value = current)
	hero.defeated.connect(func(): status.text = "Nobby ist erschöpft. Drücke F5 für einen neuen Versuch.")
	var encounters := level.get_node("Encounters")
	remaining = encounters.get_child_count()
	for marker in encounters.get_children():
		var enemy := Enemy.new()
		enemy.position = marker.position
		actors.add_child(enemy)
		enemy.defeated.connect(on_enemy_defeated)
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
		"attack": [KEY_SPACE], "shoot": [KEY_J], "menu": [KEY_ESCAPE], "summon": [KEY_R], "restart": [KEY_F5],
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
		hero.shoot_at(hero.aim_position())
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
	hud_dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hud_dock.offset_left = 12
	hud_dock.offset_right = 444
	hud_dock.offset_top = -190
	hud_dock.offset_bottom = -10
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(132,82)
	panel.size = Vector2(180,80)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("192830")
	background.border_color = Color("796443")
	background.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel",background)
	hud_dock.add_child(panel)
	health_bar = ResourceOrb.new()
	health_bar.name = "HealthOrb"
	health_bar.position = Vector2(0,0)
	health_bar.size = Vector2(96,96)
	health_bar.max_value = hero.max_health
	health_bar.value = hero.health
	hud_dock.add_child(health_bar)
	mana_bar = ResourceOrb.new()
	mana_bar.name = "ManaOrb"
	mana_bar.mana_style = true
	mana_bar.position = Vector2(40,64)
	mana_bar.size = Vector2(96,96)
	mana_bar.max_value = hero.MAX_MANA
	mana_bar.step = 0
	hud_dock.add_child(mana_bar)
	summon_button = Button.new()
	summon_button.name = "Summon"
	summon_button.text = ""
	summon_button.position = Vector2(140,82)
	summon_button.size = Vector2(72,80)
	summon_button.add_theme_font_size_override("font_size",13)
	summon_button.focus_mode = Control.FOCUS_NONE
	summon_button.tooltip_text = "Skelett erwecken · 10 Mana · bis zu 3 Begleiter für 2 Minuten.\nWASD/Pfeile: bewegen · Leertaste/J: Angriff · F5: Neustart"
	summon_button.pressed.connect(func(): hero.summon_skeleton())
	hud_dock.add_child(summon_button)
	var skeleton_icon := TextureRect.new()
	var icon := AtlasTexture.new()
	icon.atlas = load("res://assets/licensed/skeleton-stand.png")
	icon.region = Rect2(64,64,64,72)
	skeleton_icon.texture = icon
	skeleton_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	skeleton_icon.position = Vector2(4,4)
	skeleton_icon.size = Vector2(64,72)
	skeleton_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	summon_button.add_child(skeleton_icon)
	if hero.character_class == "mage":
		skeleton_icon.modulate.a = 0.35
		summon_button.tooltip_text = "Nur der Schamane kann Skelette erwecken."
	var key := Label.new()
	key.text = "R"
	key.position = Vector2(5,0)
	key.add_theme_color_override("font_outline_color",Color("16242d"))
	key.add_theme_constant_override("outline_size",4)
	key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	summon_button.add_child(key)
	shoot_button = Button.new()
	shoot_button.position = Vector2(224,82)
	shoot_button.size = Vector2(72,80)
	shoot_button.focus_mode = Control.FOCUS_NONE
	shoot_button.tooltip_text = "Linksklick: gezielt werfen · J: nächsten Gegner anvisieren"
	shoot_button.pressed.connect(func(): hero.shoot_at(hero.aim_position(false)))
	hud_dock.add_child(shoot_button)
	var arrow_icon := TextureRect.new()
	arrow_icon.texture = load("res://assets/compiled/"+("arcane-arrow.png" if hero.character_class == "mage" else "arrow.png"))
	arrow_icon.position = Vector2(20,28)
	arrow_icon.size = Vector2(32,11)
	arrow_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shoot_button.add_child(arrow_icon)
	for data in [["R · Erwecken",140],["Pfeile · J",224]]:
		var caption := Label.new()
		caption.text = data[0]
		caption.position = Vector2(data[1],164)
		caption.size = Vector2(72,14)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size",10)
		caption.add_theme_color_override("font_outline_color",Color("16242d"))
		caption.add_theme_constant_override("outline_size",3)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud_dock.add_child(caption)
	party_label = Label.new()
	party_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	party_label.position = Vector2(138,62)
	party_label.size = Vector2(170,18)
	party_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	party_label.add_theme_font_size_override("font_size",11)
	party_label.add_theme_color_override("font_color",Color("eee2c3"))
	hud_dock.add_child(party_label)
	status = Label.new()
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(status)
	status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	status.offset_left = -300
	status.offset_right = 300
	status.offset_top = 12
	status.offset_bottom = 36
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.text = "Waldlichtung · %d Wächter · Esc: Klassenwahl" % remaining
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
	summon_message.offset_top = -46
	summon_message.offset_bottom = -22
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
	party_label.text = ("Schamane · Skelette %d / 3" % count) if hero.character_class == "shaman" else "Magier · Arkane Pfeile"
	shoot_button.disabled = hero.dead or (hero.character_class == "mage" and hero.mana < 6)
	summon_button.disabled = hero.character_class != "shaman" or hero.dead or hero.mana < hero.SUMMON_COST or count >= hero.SUMMON_LIMIT

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
