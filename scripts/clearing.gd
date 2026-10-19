extends Node2D

const Art = preload("res://scripts/art_library.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const WORLD_SIZE := Vector2i(24, 18)
const TILE := 64
var hero: CharacterBody2D
var actors: Node2D
var health_bar: ProgressBar
var status: Label
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
	hero.defeated.connect(func(): status.text = "Nobby ist erschöpft. Drücke R für einen neuen Versuch.")
	for point in [Vector2(850, 570), Vector2(1050, 770)]:
		var enemy := Enemy.new()
		enemy.position = point
		actors.add_child(enemy)
		enemy.defeated.connect(on_enemy_defeated)
	build_hud()

func configure_input() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"attack": [KEY_SPACE, KEY_J], "restart": [KEY_R],
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
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(22,18)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("243541")
	background.border_color = Color("d2ad65")
	background.set_border_width_all(2)
	background.content_margin_left = 16
	background.content_margin_right = 16
	background.content_margin_top = 12
	background.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel",background)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",7)
	panel.add_child(box)
	var title := Label.new()
	title.text = "NOBBY MANA · Waldlichtung"
	title.add_theme_color_override("font_color",Color("eee2c3"))
	box.add_child(title)
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(330,18)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	var health_background := StyleBoxFlat.new()
	health_background.bg_color = Color("16242d")
	health_bar.add_theme_stylebox_override("background",health_background)
	var health_fill := StyleBoxFlat.new()
	health_fill.bg_color = Color("8ba86e")
	health_bar.add_theme_stylebox_override("fill",health_fill)
	box.add_child(health_bar)
	status = Label.new()
	status.text = "Zwei Wächter bewachen die Lichtung."
	box.add_child(status)
	var help := Label.new()
	help.text = "WASD / Pfeile: laufen    Leertaste / J: Angriff    R: Neustart"
	help.add_theme_font_size_override("font_size",15)
	box.add_child(help)

func on_enemy_defeated() -> void:
	remaining -= 1
	if remaining == 0:
		status.text = "Lichtung befreit! R startet eine neue Runde."
	else:
		status.text = "Noch ein Wächter."
